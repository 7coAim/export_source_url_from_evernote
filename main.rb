require "rexml/document"
require 'date'
require 'time'

class Entry
    attr_accessor :title, :author, :created, :updated, :source, :sourceurl
end

start_time = Time.now
entrys = {}
errors = {}

puts "== get entry source-url"

Dir.chdir("/Users/xxxx")
items = Dir.glob("*.html")

items.each_with_index do |item, index|
    
    if index + 1 < items.size
        laptime = Time.now - start_time
        avgtime = laptime / (index + 1)
        expfinishtime = avgtime * (items.size - index - 1)
        puts "Entry生成： #{index+1} / #{items.size}  #{laptime.round(2)}s  あと #{expfinishtime.round(2)}s"
    end

    # オブジェクト準備
    entry = Entry.new

    begin
    # XML形式ファイルの読み込み
    doc = REXML::Document.new(File.open(item))

    # title取得
    entry.title = doc.elements["//html/head/title"].text
    
    # meta取得
    doc.each_element("//html/head/meta") do |meta|
        meta_name = meta.attributes['name']
        meta_content = meta.attributes['content']
        case meta_name
        when "created" then
            entry.created  = meta_content
        when "source" then
            entry.source  = meta_content
        when "source-url" then
            entry.sourceurl  = meta_content
        when "updated" then
            entry.updated  = meta_content
        when "author" then
            entry.author  = meta_content
        end
    end
    
    # createdがnilの場合の対応
    entry.created = "1990-01-01 00:00:00 +0000" if entry.created == nil

    entrys[entry.created] = entry

    rescue => error
        errors[item.to_s] = error
    end
end



puts "== Sort #{(Time.now - start_time).round(2)}s"
# createdでソート
entrys2 = entrys.sort_by do |k, v|
    DateTime.parse(v.created)
end

puts "== Output #{(Time.now - start_time).round(2)}s"

dom1 = <<-EOS
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!-- This is an automatically generated file.
     It will be read and overwritten.
     DO NOT EDIT! -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks_from_evernote</TITLE>
<H1>Bookmarks_from_evernote</H1>
<DL><p>
    <DT><H3 ADD_DATE="1547439471" LAST_MODIFIED="1547439550">_from_evernote</H3>
    <DL><p>
EOS

dom2 = <<-EOS
    </DL><p>
</DL><p>
EOS


Dir.chdir("/Users/xxxx")
File.open('output.html', 'w') do |file|
    file.puts(dom1)

    entrys2.each do |k, v|
        if v.sourceurl != nil
            file.puts("<DT><A HREF=\"#{v.sourceurl}\" ADD_DATE=\"#{Time.parse(v.created).to_i}\">#{v.title}</A>")        
        end
        
        
    end

    file.puts(dom2)
end


puts "== Csv #{(Time.now - start_time).round(2)}s"
File.open('output.csv', "w:UTF-8") do |file|
    bom = "012"
    bom.setbyte(0, 0xEF)
    bom.setbyte(1, 0xBB)
    bom.setbyte(2, 0xBF)
    file.print bom

    file.puts "\"title\",\"author\",\"created\",\"updated\",\"source\",\"sourceurl\""

    entrys2.each do |k, v|
        file.puts "\"#{v.title}\",\"#{v.author}\",\"#{v.created}\",\"#{v.updated}\",\"#{v.source}\",\"#{v.sourceurl}\""
    end
end

puts "== Finished #{(Time.now - start_time).round(2)}s"

puts "-- ErrorList"
errors.each do |k, v|
    puts k
end
