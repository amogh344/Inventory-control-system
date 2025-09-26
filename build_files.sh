#!/bin/bash

# 1. Install all Python packages from your requirements file
pip3 install -r backend/requirements.txt

python3 manage.py makemigrations

# 2. Run database migrations against your live database
python3 manage.py migrate
