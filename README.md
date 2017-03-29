Doc Center
============

(alternatively: doctor centaur, dock centre, etc.)

##Getting Started
### Do these things once (BEFORE `bundle install`!):
1. install RVM `\curl -#L https://get.rvm.io | bash -s stable --autolibs=3 --ruby`
2. make sure RVM is the most up to date version: `rvm get stable`
3. install homebrew `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
4. run `brew update` to make sure you have the most recent version
5. run `brew doctor` to make sure everything is good to go
6. `brew install postgresql` and run the command it gives you to make postgres boot on startup
7. `brew install imagemagick`
8. `brew install phantomjs`
9. `brew install redis` and run the command it gives you to make redis boot on startup
10. `brew install elasticsearch`
11. install ruby 1.9.3-p429 `rvm install ruby-1.9.3-p429`

### Then:
1. clone this repo
2. `cd` to that location
3. `gem install zeus`
4. `bundle install`
5. get copies of database.yml and environment.rb from Dan/AlexE
6. create the database table `createdb doc_center`
7. get the schema loaded and seed data into it `rake db:setup`
8. prep your test db `rake db:test:prepare`
9. (if you get permission/role errors try the following DO NOT DO THIS UNLESS YOU GET ERRORS)
10. create a pg user for your username `sudo -u postgres createuser <username>`
11. add the createdb permission `sudo -u postgres psql -c 'alter user <username> with createdb' postgres

###Launching the Doc Center  
10. run: `zeus start`
11. in a new terminal tab (in the project directory) run: `zeus s`
11. Start Resque: `bundle exec rake jobs:work QUEUE=high_priority_pdfs,'*' IS_A_RESQUE_WORKER=true`
12. in a browser, navigate to `ad.docs.lvh.me:3000`
13. login with your AppDirect credentials (you might get a 403 when it redirects you, that's fine.)
14. in a new terminal tab (in the project directory) run: `zeus c`
15. once the rails/zeus console boots up run: `User.find_by_email("[YOUR APPDIRECT ACCOUNT EMAIL]").add_role(:superadmin)`
16. refresh the page in your browser, you should be in!

## Useful Commands:
2. Startup the Resque queue: `bundle exec rake jobs:work QUEUE=high_priority_pdfs,'*' IS_A_RESQUE_WORKER=true` at application startup.
3. Start the clock process: `bundle exec clockwork clock.rb`
3. Start elasticsearch: `elasticsearch --config=/usr/local/opt/elasticsearch/config/elasticsearch.yml`
3. `zeus start` to run zeus
4. `zeus s` to run the server (while zeus is running)
4. `zeus c` to run the console (while zeus is running)
5. `zeus rspec spec` to run the tests (while zeus is running) `zeus rspec spec/<folder>/<file>` to run a single test file
6. `cd /usr/local/opt/elasticsearch/` and then `bin/plugin -i elasticsearch/marvel/latest` to install marvel for elasticsearch which can be loaded from your browser: `http://localhost:9200/_plugin/marvel/` after you restart elasticsearch

##Navigating the Project
+ Most everything you'll need to mess with will be found in the /app folder
+ Stylesheets are in /app/assets/stylesheets browser stylesheets are in the 'all' folder, print specific are in the 'print' folder
+ Coffeescripts are in /app/assets/javascripts
+ Plugins (bootstrap, localScroll, etc.) are in /vendor/assets/javascripts. The associated stylesheets are in /vendor/assets/stylesheets


## Databases
+ List all your local pg databases: `psql -l`
+ Manually triggering a backup: `heroku pg:backups capture --app doc-center-dev` (or whatever app you want to backup)
+ Download the backup to your local machine: `curl -o latest.dump `heroku pg:backups public-url --app doc-center-dev`` (or whatever app)
+ Import the .dump file to your local machine: `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U [USERNAME] -d [DATABASE_NAME] latest.dump
+ Import the production server to staging: heroku pgbackups:restore DATABASE -a doc-center-dev `heroku pgbackups:url -a doc-center`
+ More on pgbackups: https://devcenter.heroku.com/articles/pgbackups

## FAQs
### "Connection error" on login or SSL certificate errors
+ run `rvm osx-ssl-certs update`
+ Note the path you get from that command and adjust the following symlink command accordingly:
+ run sudo `mkdir -p /etc/ssl/certs/ ; sudo ln -s /usr/local/etc/openssl/cert.pem /etc/ssl/certs/ca-certificates.crt`
