require 'pastebin'

DIR = File.expand_path(File.join(__FILE__, '..'))
api_key_file = "#{DIR}/.pastebin-api-key"

if ! File.exist?(api_key_file)
  raise "Put pastebin API key here: #{api_key_file}"
end

api_key = File.read(api_key_file)

Pastebin.send(:remove_const, :DEVKEY)
Pastebin.const_set(:DEVKEY, api_key)

files = %w(
  userIo
  tablePersistence
  startup
  stockpile/craftingRequester
  stockpile/itemSearcher
  stockpile/settingsPersistence
)
pastebin_keys = {}

files.each do |file|
  file_contents = File.read("#{DIR}/../#{file}")
  pastebin_keys[file] = Pastebin.new(api_paste_code: file_contents).paste.split('/').last
end

installer_code = <<-CODE
-- This installer is generated automatically. For the latest version,
-- please visit: http://github.com/sidoh/stockpile
CODE

pastebin_keys.each do |key, file|
  installer_code << "shell.run('pastebin', 'get', '#{key}', '#{file}')\n"
end

installer_code << <<-CODE
sleep(1)
shell.run("startup")
CODE

puts Pastebin.new(api_paste_code: installer_code).paste
