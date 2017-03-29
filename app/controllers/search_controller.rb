class SearchController < ApplicationController
  def index
    q = params[:q]
    redirect_to(:back, notice: "Please enter a query to search for") unless q.present?
    index = params[:index]
    time = params[:time]
    orderby = params[:sort]
    book_title = params[:book_title]

    # nevermind this for the moment. Best_fields was introduced in 1.1.0 and bonsai is on 1.0.2
    # q_split = q.split
    # if q_split.count > 1
    #   type = "phrase"
    # else
    #   type = "best_fields"
    # end

    # if the anon user tries to change the index we're searching, change it back to Api
    index = "Api" unless current_user

    stripped_q = stopword_filter_query(q)
    #stripped_q = q

    # sufficiently long ago to cover the entire history of the doc center
    # TODO: change this to be a dynamically added filter
    from_time = 5.years.ago

    if time.present?
      if time != "6_months"
        from_time = 1.send(time).ago
      else
        from_time = 6.months.ago
      end
    end


    #results = Release.search q, fields: [:public_content, "#{channel_partner_paramd}_content".intern]
    json = {
              size: 50,
              query: {
                filtered: {
                  query: {
                    multi_match: {
                      query: stripped_q,
                      fields: ["public_content",  "title^2"]
                    }
                  },
                  filter: {
                    bool: {
                      must: [{ 
                        range: {
                          date: {
                            from: from_time
                          }
                        } 
                      }]
                    }
                  }
                }
              },
              highlight: {
                pre_tags: ["<em class='highlight'>"],
                post_tags: ["</em>"],
                fields: {
                  "public_content" => { "fragment_size" => 250, "number_of_fragments" => 3 },

                  "title" => { "fragment_size" => 250, "number_of_fragments" => 3 }
                }
              }
            }

    add_sorting(json) if orderby != "_score" and orderby.present?
    # add_channel_partner(json) if current_user
    scope_to_book(json, book_title) if book_title

    results = Release.search(json: json,
                             index_name: which_index(index)).with_details

    @term = q
    @headline_add = headline_addendum(index, book_title)
    @book = book_title if book_title.present?
    @results = results
    #log_no_results(@term) if @results.empty?
  end

  private

  def log_no_results(query)
    require 'elasticsearch'

    index = "no_result_queries"
    host = ENV["BONSAI_URL"] || "localhost:9200"

    client = Elasticsearch::Client.new host: host

    client.indices.create index: index unless client.indices.exists index: index

    client.index index: index, type: "no_results", body: { "@timestamp" => DateTime.now, :term => query, :user => current_user, :partner => current_user.channel_partner.name }
  end

  def stopword_filter_query(q)
    # STOPWORDS is definied in initializers/constants.rb
    # http://stackoverflow.com/questions/4655194/simple-filtering-out-of-common-words-from-a-text-description
    common = {}
    STOPWORDS.each{|w| common[w] = true}
    stopped = q.gsub(/\b\w+\b/){|word| common[word.downcase] ? '': word}.squeeze(' ')
    return stopped
  end

  def headline_addendum(index, book_title)
    case index
    when "Release"
      return "in Release Notes"
    when "Faq"
      return "in FAQs"
    when "Roadmap"
      return "in Roadmaps"
    when "Manual"
      return "in Manuals"
    when "Support"
      return "in Support Guides"
    when "Api"
      case book_title
      when nil
        return "in Documentation"
      else
        return "in #{book_title}"
      end
    else
      return ""
    end
  end

  def which_index(index)
    if index == "All"
      return [Release.searchkick_index.name,
              Manual.searchkick_index.name,
              Support.searchkick_index.name,
              Faq.searchkick_index.name,
              Roadmap.searchkick_index.name,
              Api.searchkick_index.name]
    else
      return [index.camelize.constantize.searchkick_index.name]
    end
  end

  def add_channel_partner(query)
    channel_partner_paramd = current_user.channel_partner.name.parameterize
    if current_user.can_see_all?
      query[:query][:filtered][:query][:multi_match][:fields].push("*_content")
      query[:highlight][:fields]["*_content"] = { "fragment_size" => 250, "number_of_fragments" => 3 }
    else
      query[:query][:filtered][:query][:multi_match][:fields].push("#{channel_partner_paramd}_content")
      query[:highlight][:fields]["#{channel_partner_paramd}_content"] = { "fragment_size" => 250, "number_of_fragments" => 3 }
    end
  end

  def scope_to_book(json, book_title)
    json[:query][:filtered][:filter][:bool][:should] = [{ :term => { :book => book_title } }]
  end

  def add_sorting(json)
    split_param = params[:sort].split(/-/)
    field = split_param[0]
    direction = split_param[1]

    json["sort"] = [
      { "#{field}" => { order: direction } }
    ]

    return json
  end
end
