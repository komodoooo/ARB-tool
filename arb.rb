#!usr/bin/env ruby
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'socket'
require 'colorize'


def help
    puts """\n
ARB commands:
lookup       => show infos of an user target (ip/domain)
portscan     => check the open port on a target (ip/domain)
ssl          => check the ssl certificate (ip/domain)
headers      => returns the headers of a site
fingerprint  => capture the html code of a site
linkshunt    => view the correlated links in a site
xml-parser   => parse an xml document of a site
fuzzer       => do the directory fuzzing in a site
-r           => reset & clear display
banner       => show the banner
help         => help you :kek:
exit         => exit\n""".light_magenta
end

def logo
    banner = '''
                  ___
 ▄▀█ █▀█ █▄▄     / | \ 
 █▀█ █▀▄ █▄█    |--0--|
                 \_|_/        By LoJacopS
'''.cyan[..-5]
    print banner
    puts "v2.0.1\n"
    print Time.now
    puts "\nPress [enter] to start\n"
end

=begin

Komodo, 5/02/2022
Hi reader of this code, i'm sorry for eventually
shitty codes in arb. It was my first ruby project in 2020...
Right now, I update it in randomly moments

=end

print logo
puts "Welcome to arb!"
prompt = "\rArb>".green[..-5]
class Commands 
    def headers(target)
        Thread.new{
            begin
                urii = URI(target)
                response = Net::HTTP.get_response(urii) 
                response.to_hash['set-cookie']                      #get the sexy headers
                puts "Headers:\n #{response.to_hash.inspect.gsub("],","],\n")}".yellow
            rescue Errno::ENOENT, Errno::ECONNREFUSED, SocketError
                puts "\rselect a valid target! (example https://pornhub.com)".red
            end
        }.join
    end
    def lookup(oscuro)
        urrah = URI("https://ipwhois.app/json/#{oscuro}")
        mlml = Net::HTTP.get(urrah)
        puts "\n"
        puts mlml.gsub(",", ",\n").yellow
    end
    def fingerprint(body)
        begin
            puts "\rhere the html code\n"
            body_capture = Net::HTTP.get_response(URI(body))                 
            print "\n#{body_capture.body.yellow}\n"
        rescue Errno::ENOENT, Errno::ECONNREFUSED
            puts "\rselect a valid target! (example https://pornhub.com)".red
        rescue ArgumentError => ah 
            puts "\rERROR: #{ah}".red
        end
    end
    def linkshunt(site)
        Thread.new{
                begin      
                    puts "\rtarget selected: #{site}"
                    doc = Nokogiri::HTML(open(site))
                    element = doc.at_xpath("//a/@href")
                    element.map{|amogus| amogus.value}
                    nodeset = doc.css('a[href]')
                    yay = nodeset.map {|element| element["href"]}
                    puts "\nCorrelateds link at #{site}:\n".yellow
                    yay.each do |link|
                        puts "\r#{link}".yellow
                    end
                rescue => eeeeh
                    puts "ERROR\n#{eeeeh}".red
                    puts ""
                end
        }.join
    end
    def scan_port(domain)  
        ports = [15,21,22,23,25,26,50,51,53,67,58,69,80,110,119,123,
                135,139,143,161,162,200,389,443,587,989,990,
                993,995,1000,2077,2078,2082,2083,2086,      #most used ports
                2087,2095,2096,3080,3306,3389,8843
            ]      
        #ports = Range.new(1,5000)      Ranges? Nah.
        begin
            for numbers in ports
                socket = Socket.new(:INET, :STREAM)
                remote_addr = Socket.sockaddr_in(numbers, domain)
                begin
                    socket.connect_nonblock(remote_addr)
                rescue Errno::EINPROGRESS
                    #next
                end
                time = 1
                sockets = Socket.select(nil, [socket], nil, time)
                if sockets
                    puts "\rPort #{numbers} is open".yellow
                else
                    puts "\rPort #{numbers} is closed".red
                end
            end
        rescue SocketError => sock_err
            puts "ERROR\n#{sock_err}".red
            puts ""
        end
    end
    def xml_parser(document)
        begin
            ehm = Nokogiri::XML(open(document)) do |config|  
                puts "#{config.strict.noblanks}".yellow[..-5]
            end
            print ehm
            puts "\nAll saved in the file document.xml!"
            document = File.new("document.xml", 'a')
            document.write(ehm)
            document.close()
        rescue Errno::ENOENT, Errno::ECONNREFUSED, Nokogiri::XML::SyntaxError, URI::InvalidURIError, OpenURI::HTTPError
            puts "\rselect a valid target! (example https://google.com/sitemap.xml)".red
        end
    end
    def fuzzer(link, wordlist)
        begin
            Thread.new{
                wordlist = File.open(wordlist)
                ohyes = wordlist.map {|x| x.chomp }
                ohyes.each do |dir|
                    uriiii = URI("#{link}/#{dir}/")
                    requestt = Net::HTTP.get_response(uriiii)
                    if requestt.code == '200'
                        puts "\ndirectory open! '#{dir}'".yellow
                        log = File.new("valid.log", "a")
                        log.write(dir+"\n")
                        log.close()
                        puts "saved on file valid.log!".yellow
                    else
                        puts "\nscanning...#{requestt.code}".cyan                    #directory closed
                    end
                end
            }.join
        rescue Errno::ENOENT, Errno::ECONNREFUSED
            puts "\rERROR: Select a valid wordlist! (make sure that file of wordlist is on the same path)".red
        rescue Net::OpenTimeout
            puts "\rERROR: Select a valid target! example: http://pain.net".red
        rescue => eeeh
            puts "ERROR\n#{eeeh}".red
            puts ""
        end
    end
    def sexssl?(oscuro)
        ssl = true
        string = "\n#{oscuro} ssl certificate:"
        begin
            URI.open("https://#{oscuro}")
            puts "#{string} #{ssl}\n\n".yellow[..-5]
        rescue OpenSSL::SSL::SSLError, Errno::EHOSTUNREACH
            ssl = false
            puts "#{string} #{ssl}\n\n".yellow[..-5]
        rescue SocketError, NoMethodError => lmao 
            puts "\nSelect a valid target! (example www.google.com)".red[..-5]
            puts lmao
            nil
        end
    end
end
while (input = gets.chomp)
break if input == "exit"
    exec = Commands.new()
    print prompt && input
    if input == "headers"
        print "\rTarget: "
        sessoinput = gets.chomp
        exec.headers(sessoinput)
    elsif input == "lookup"
        Thread.new{
            puts "\rRemember to select a valid target! (example www.twitter.com or 104.244.42.1)".red
            print "\rSelect a valid target: ".green
            url_target = gets.chomp
            exec.lookup(url_target) do |output|
                print output
                puts "\n"
            end
        }.join
    elsif input == "fingerprint"
        puts "\rinsert a site target: "
        pazzo = gets.chomp
        exec.fingerprint(pazzo)
    elsif input == "linkshunt"
        puts "\rinsert a link:"
        url = gets.chomp
        exec.linkshunt(url)
    elsif input == "portscan"
        puts "(example: www.google.com)"
        print "\rtype an ip to check the ports open on: "
        scan_target = gets.chomp
        exec.scan_port(scan_target)
    elsif input == "xml-parser"
        print "\rSite with xml: "
        xmlml = gets.chomp
        exec.xml_parser(xmlml)
    elsif input == "fuzzer"
        print "\rlink: "
        fuzz_target = gets.chomp
        print "\r(type default for use the default wordlist)\nselect a wordlist: "
        wordlist_option = gets.chomp
        if wordlist_option == "default"
            wordlist = Net::HTTP.get(URI("https://raw.githubusercontent.com/komodoooo/dirfuzzer/main/wordlist.txt"))
            writereq = File.new("wordlist.txt", "a")
            writereq.write(wordlist)
            writereq.close()
            puts "\nCreated file wordlist.txt!".yellow
            exec.fuzzer(fuzz_target, "wordlist.txt")
        else 
            exec.fuzzer(fuzz_target, wordlist_option)
        end 
    elsif input == "ssl"
        puts "\rExample: sex.com"
        print "\rTarget: "
        ssl_target = gets.chomp
        exec.sexssl?(ssl_target)
    elsif input == "-r"
        system('clear||cls')
        puts "Resetted!".cyan
        puts "\n"
    elsif input == "help"
        print help
    elsif input == "banner"
        print logo
    else 
       nil
    end
    print prompt
    system(input)
end