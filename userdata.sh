#!/bin/bash
 sleep 300
 sudo su
 amazon-linux-extras install -y ansible2
 ansible-playbook tomcat-setup.yaml
