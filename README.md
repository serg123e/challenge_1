
## How to configure ##

* `gem install aws-sdk`

* `export AWS_ACCESS_KEY_ID=...`
  `export AWS_SECRET_ACCESS_KEY=...`

* edit config/aws.yml

* create RDS MySQL instance an edit config/aws.yml accordingly

* run `rake aws:deploy` to create Lambda function

* in AWS Console configure environment variable of created lambda function:

  `CHALLENGE_API_URL`: `SAMPLE`

  (use `SAMPLE` to use sample data instead of fetching an external API)
 
* configure VPC and SecurityGroup to allow the function to acces to MySQL

## How to deploy ##

to update the function configured before, run `rake aws:update`