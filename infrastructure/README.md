# Infrastructure

This is the directory where we are going to work with our infrastructure.

### Set up your aws credentials

Before start working with terraform and aws, you need to set up your credentials.
The next tree structure details where we are going to store our credentials:
  
``` bash
-> infrastrucutre (current directory)
   |
   --->.aws
       |
	   --->config.txt
```

The .aws directory is not going to be tracked by git if you follow the tree structure. 

The config.txt file should contain your profiles (one for the aws dev account and one for the aws prod account).
To find your credentials you should log in into the AWS access portal of this organization.
Once in the portal, expand the account that you want to get your access keys and click on *Access Keys*.
Scroll down until you find option 2. Copy the text and past it in the config.txt file.
Edit the text that is between the square brackets: 
> Delete the content that is between the square brackets and type **profile 'name'** where **'name'** name is an identifier for your profile so you can put anything.

Now you are going to repeat the process with the other account.
After adding the credentials for both accounts, include:
```
[default]
region = us-east-1
```

This how your config.txt file should look after this process. 
```
[default]
region = us-east-1

[profile dev]
aws_access_key_id = 12345
aws_secret_access_key = 12345
aws_session_token = 12345

[profile prod]
aws_access_key_id = 12345
aws_secret_access_key = 12345
aws_session_token = 12345
```

### Test your credentials

Once you configured your credentials, go to the test.tf file located in the **test-credentials** directory. In the provider block, change the profile: type any of your profiles identifiers in the profile attribute. Finally run the next commands on **test-credentials** directory:
```terraform init``` and then ```terraform plan```


> **Note:** Using IAM Identity Center, AWS reset you credential after a period of time. If you face the next error: *The security token included in the request is expired*, update your credentials by copying and pasting the new credentials generated by AWS in the AWS Acess Portal.