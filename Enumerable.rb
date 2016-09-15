#!/usr/bin/env ruby

module Enumerable

  def my_each
    for i in self do
       yield i
    end
  end

  def my_each_with_index
    is=0
    for i in self do
       yield i, is
     is+=1
    end
  end

  def my_select(&block)
    self.my_each{ |x| p x if block.call(x) }
  end

  def exec(data,&block)
    @result=[]
    data.my_each do |x|
      begin
        (block.call(x)) ? (@result << true) : (@result << false)
      rescue
        @result << false
      end
    end
  end

  def my_all?(&block)
    data=self
    exec(data,&block)
    (@result.include?(false)) ? (p false) : (p true)
  end

  def my_any?(&block)
    data=self
    exec(data,&block)
    (@result.include?(true)) ? (p true) : (p false)
  end

  def my_count(&block)
    data=self
    result=0
    if block_given?
      data.my_each do |x|
        exec(data,&block)
        result+=1 if (@result.include?(true))
      end
    else
      data.my_each do |x|
        result+=1
      end
    end
      p result
  end

  def my_map(&block)
    data=self
    data.my_each { |i| p block.call(i) }
  end


[1,2,3].my_map{|i| i*i}

end
