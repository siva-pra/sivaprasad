# Ansible Playbook: Copy files to AWS S3 bucket

This Ansible playbook is used to copy files to an AWS S3 bucket and enable static web hosting for the bucket.
Requirements

    Ansible installed on the local machine
    AWS access key and secret key
    AWS CLI installed on the local machine

## Usage

    Clone the repository:

bash

git clone https://github.com/your-username/your-repository.git

    Navigate to the project directory:

bash

cd your-repository

    Edit the aws_s3.yml file and update the bucket_name, index_document, and error_document variables as per your requirements.

    Run the playbook:

ansible-playbook aws_s3.yml

## Playbook

The playbook aws_s3.yml contains the following tasks:

    Create a new S3 bucket.
    Copy the index.html file from the local machine to the S3 bucket.
    Copy the styles.css file from the local machine to the S3 bucket.
    Enable public access and ACL for the S3 bucket.
    Enable static web hosting for the S3 bucket.

yaml

---
- name: cp files to aws s3 bucket
  hosts: localhost
  connection: local 
  vars:
    bucket_name: s3sivansible
    index_document: index.html
    error_document: error.html
  tasks:
    
    - name: Create new bucket
      aws_s3:
        bucket: "{{ bucket_name }}"
        mode: create
        region: us-west-2
    
    - name: Simple copy index.html
      amazon.aws.s3_object:
        bucket: "{{ bucket_name }}"
        object: index.html
        src: /home/siva/index.html
        mode: put
    
    - name: Simple copy styles.css
      amazon.aws.s3_object:
        bucket: "{{ bucket_name }}"
        object: styles.css
        src: /home/siva/styles/styles.css
        mode: put
        
    - name: Enable public access and ACL for S3 bucket
      shell: |
        aws s3api put-bucket-acl --bucket {{ bucket_name }} --acl public-read
        aws s3api put-bucket-policy --bucket {{ bucket_name }} --policy '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":"*","Action":["s3:GetObject"],"Resource":["arn:aws:s3:::{{ bucket_name }}/*"]}]}'

    - name: Enable static web hosting for S3 bucket
      shell: |
        aws s3 website s3://{{ bucket_name }} --index-document {{ index_document }} --error-document {{ error_document }}

## License

This project is licensed under the MIT License - see the LICENSE file for details.