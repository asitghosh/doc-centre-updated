web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: bundle exec rake jobs:work QUEUE=high_priority_pdfs,'*' IS_A_RESQUE_WORKER=true
clock: bundle exec clockwork clock.rb