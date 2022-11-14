# lightfeather-code-challenge
VPC chart -

<img src="https://imgur.com/a/ZotyZFM" width="50%" height="50%">

repo for code challenge

This repo holds terraform code that will launch the code challenge app in a VPC environmet across 3 availability zones in us-east-1 (North Virginia) 
Terraform will create the infrastructure for:

* 1 VPC
* 3 public subnets
* 1 internet gateway
* 1 public routing table
* 1 security group
* 3 ec2 instances across 3 availability zones

Automated commands are sent to the server where the application is installed after retreiving the data from the forked code repo that holds the application files.

Note:
While not provisioned in the terraform code, Docker images were also created from the application data files and stored on DockerHub. The addresses to the containers are:
Frontend - https://hub.docker.com/r/dkrtomobi/frontend-lightfeatherapp
Backend - https://hub.docker.com/r/dkrtomobi/backend-lightfeatherapp

# Requirements:
- Visual Studio Code (or similar editor)
- Terraform installation
- AWS CLI
- AWS Account
- A KeyPair downloaded onto working computer
- Git

# install Git:
Visit the git webpage and download Git onto your system. Run the executible and click next through all options to install Git.
`
https://git-scm.com/downloads
`

# Install Terraform:
Visit terraform.io downloads page and download terraform onto your system
`
https://developer.hashicorp.com/terraform/downloads
`
Add a path to the executable to your enviroment variables

# Install AWS CLI:
Follow this guide to download and set up aws cli:
`
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
`
Ensure that you have run 'aws configure' in the command prompt or VS Code terminal to set up the cli.

# Set up Environment:
* Create a folder on the desktop called 'CodeChallenge'
* Create a folder in CodeChallenge called 'KeyPair'
* Open VS code and open the terminal by clicking View > Terminal from the top menu.

# Download Repository:
* Ensure the terminal in VS Code is in the CodeChallenge folder. If not, change directory 
using the 'cd' command to the CodeChallenge directory.
* Type into the terminal the following:
`
git clone https://github.com/GitTomobi/lightfeather-code-challenge.git
`
* Press ENTER. The repository containing the terraform code should download as a folder 
called "light-feather-code-challenge".

# Download KeyPair:
* Log into AWS
* Use the aws searchbar and go to EC2 > Instances
* Click launch instances
* Scroll down to key pair section and click "Create new keypair"
* Choose RSA and .PEM as your options and provide it a distinguishable name.
* Click create key pair and it will download to your local machine.
* Move the Keypair into your CodeChallenge > KeyPair folder.

# Update code with keypair name
* On line 99, replace [YOUR_KEY_PAIR_NAME] with the name of your downloaded keypair file.
* On line 105, replace [YOUR_KEY_PAIR_NAME] with the name of your downloaded keypair file. Ensure the '.pem' remains

#Initialize and run terraform code:
* In VS Code terminal, change directory using 'cd' command into the 'light-feather-code-challenge' directory.
Type into the terminal:
`
terraform init
`
`
terraform plan
`
`
terraform apply --auto-approve
`

Navigating to the public ip address for any of the 3 instances and appending the port of :3000 after the ip address will open the webapp and display the guid.
