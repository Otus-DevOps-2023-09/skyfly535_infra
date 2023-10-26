#!/bin/bash

# Установка Ruby

sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential

# Проверка версий Ruby и Bundler

ruby -v
bundler -v
