require 'csv'
require 'date'
require 'json'

def parse
  CSV.foreach('./logfile.log', col_sep: ' ').each_with_object({}) do |row, hash|
    url = row[5]
    date = "#{row[3][1..-1]}"
    hash[url.to_sym] ||= {requests: 0, accessed_dates: []}
    hash[url.to_sym][:requests] += 1
    hash[url.to_sym][:accessed_dates] << DateTime.strptime(date, '%d/%b/%Y:%H:%M:%S')
  end
end


result = parse
sorted_results = result.sort{|it, other| other[1][:requests] <=> it[1][:requests] }.to_h


#### 1

results_july_first = parse

selected_date = Date.new(1995, 07, 01)

results_july_first.each do |key, value|
  value[:accessed_dates].select!{|it| it.to_date ===  selected_date }
end
    .reject!{|key, value| value[:accessed_dates].empty? }

results_july_first = results_july_first.sort{|it, other| other[1][:accessed_dates].size <=> it[1][:accessed_dates].size}.to_h
most_visited_1 = results_july_first[results_july_first.keys[0]]



#### 2.
results_not_july_first = parse

results_not_july_first.each do |key, value|
  value[:accessed_dates].reject!{|it| it.to_date ===  selected_date }
end
    .reject!{|key, value| value[:accessed_dates].empty? }

results_not_july_first = results_not_july_first.sort{|it, other| other[1][:accessed_dates].size <=> it[1][:accessed_dates].size}.to_h
most_visited_2 = results_not_july_first[results_not_july_first.keys[0]]


#### 3.

output = result.each_with_object([]){|kvp, array|
  array << kvp[1][:accessed_dates].map {|date| {date: date, url: kvp[0]}}
}
output.flatten!


output = output.sort_by{|it| it[:date]}

File.open('output.txt', 'w+') do |f|
  output.each{|element| f.puts("#{element[:date].rfc3339} #{element[:url]}")}
end
