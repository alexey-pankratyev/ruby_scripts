#!/usr/bin/ruby
# coding: utf-8
# @av.pankratev@tensor.ru
require 'rbvmomi'
require 'trollop'
require_relative  'vmcon'

module Vmcon

     HOST={host: 'vc.corp.tensor.ru', user: ARGV[0], password: ARGV[1] , insecure: true}

    def convm(st)
      vim = RbVmomi::VIM.connect st
      rootFolder = vim.serviceInstance.content.rootFolder or raise "VM not found"
      return  rootFolder
    rescue => e
      puts("Connect error: #{e}")
    end

    def con(st)
      vim = RbVmomi::VIM.connect st
      return vim
    end

end
