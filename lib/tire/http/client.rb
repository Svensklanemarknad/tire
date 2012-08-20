module Tire

  module HTTP

    module Client

      class RestClient
        ConnectionExceptions = [::RestClient::ServerBrokeConnection, ::RestClient::RequestTimeout]

        def self.get(url, data = nil)
          request :get, url, data
        end

        def self.post(url, data)
          request :post, url, data
        end

        def self.put(url, data)
          request :put, url, data
        end

        def self.delete(url)
          request :delete, url
        end

        def self.head(url)
          request :head, url
        end

        private

        def self.request(method, url, data = nil)
          begin
            perform ::RestClient::Request.execute(method: method, url: url, payload: data)
          rescue ::RestClient::ServerBrokeConnection
            r = (r || 0) + 1 and r < 5
            raise "perform tried #{r} times #{$!.to_s}"
          rescue *ConnectionExceptions
            raise
          rescue ::RestClient::Exception => e
            Response.new e.http_body, e.http_code
          end
        end

        def self.perform(response)
          Response.new response.body, response.code, response.headers
        end

      end

    end

  end

end
