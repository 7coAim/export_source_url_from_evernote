require "rexml/document"
require 'date'

class Entry
    attr_accessor :title, :author, :created, :updated, :source, :sourceurl
end

start_time = Time.now
entrys = {}

puts "== get entry source-url"

# ディレクトリへ移動
Dir.chdir("/Users/ntdk/gomi_html")

# パターンマッチングでディレクトリ内のエントリ一覧を取得
items = Dir.glob("*.html")

items.each_with_index do |item, index|
    
    laptime = Time.now - start_time
    puts "Entry生成： #{index+1} / #{items.size}  #{laptime.round(2)}s"

    # オブジェクト準備
    entry = Entry.new

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
end

puts "== Sort"
# createdでソート
entrys.sort_by do |k, v|
    DateTime.parse(v.created)
end

puts "== Output"


puts "== Finished"


