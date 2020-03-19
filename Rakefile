# frozen_string_literal: true
require 'yaml'
aws_config = YAML.safe_load(File.open('config/aws.yml'))

namespace :aws do
  desc 'Prepare a zip file for upload to AWS'
  task :zip do
    system('zip -rf function.zip spec models db config app.rb challenge.rb lib vendor')
  end

  desc 'Deploy function to AWS'
  task :deploy do
    Rake::Task['aws:zip'].invoke
    require 'aws-sdk-lambda'
    p aws_config
    client = Aws::Lambda::Client.new(region: aws_config['region'])

    args = {}

    args[:role] = aws_config['role']
    args[:function_name] = aws_config['function_name']
    args[:handler] = aws_config['handler']
    args[:runtime] = aws_config['runtime']

    code = {}
    code[:zip_file] = File.open('function.zip','rb').read
    args[:code] = code

    client.create_function(args)    
    puts 'Function created.'    
  end


  desc 'Update AWS Lambda function'
  task :update do    
    Rake::Task['aws:zip'].invoke
    require 'aws-sdk-lambdapreview'
    client = Aws::LambdaPreview::Client.new(region: aws_config['region'])

    args = {}
    args[:role] = aws_config['role']
    args[:function_name] = aws_config['function_name']
    args[:handler] = aws_config['handler']
    args[:runtime] = aws_config['runtime']

    args[:mode] = "event"
    args[:function_zip] = File.open('function.zip','rb').read

    client.upload_function(args)    
    puts 'Function updated.'    
  end


  desc 'Invoke AWS Lambda function'
  task :invoke do    
    require 'aws-sdk-lambda'
    client = Aws::Lambda::Client.new(region: aws_config['region'])

    resp = client.invoke({
                         function_name: aws_config['function_name'],
                         invocation_type: 'RequestResponse',
                         log_type: 'None',
                         payload: ''
                       })

    p resp
    puts resp.payload.string
    
  end
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  puts no rspec available
end
