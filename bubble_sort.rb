#!/usr/bin/env ruby

  def bubble_sort(*args)
     mas = []
     args.map{ |i| mas.push(i) }
     p mas.each{ |i| (mas.length-1).times{ |i| mas[i],mas[i+1]=mas[i+1],mas[i] if mas[i] > mas[i+1] }}
  end

bubble_sort(2, 5, 15,1, 6, 3, 9)
