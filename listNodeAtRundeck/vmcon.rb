#!/usr/bin/ruby
# coding: utf-8
# @av.pankratev@tensor.ru
require 'rbvmomi'
require_relative  'vmcon'

module Vmcon

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
