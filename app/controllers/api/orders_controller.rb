require 'net/http'

module Api
    class OrdersController < ApplicationController
        STATES = {
            "Acre": "AC",
            "Alagoas": "AL",
            "Amapá": "AP",
            "Amazonas": "AM",
            "Bahia": "BA",
            "Ceará": "CE",
            "Espírito Santo": "ES",
            "Goiás": "GO",
            "Maranhão": "MA",
            "Mato Grosso": "MT",
            "Mato Grosso do Sul": "MS",
            "Minas Gerais": "MG",
            "Pará": "PA",
            "Paraíba": "PB",
            "Paraná": "PR",
            "Pernambuco": "PE",
            "Piauí": "PI",
            "Rio de Janeiro": "RJ",
            "Rio Grande do Norte": "RN",
            "Rio Grande do Sul": "RS",
            "Rondônia": "RO",
            "Roraima": "RR",
            "Santa Catarina": "SC",
            "São Paulo": "SP",
            "Sergipe": "SE",
            "Tocantins": "TO",
            "Distrito Federal": "DF"
        }

        def handle
            created_at = DateTime.parse(handle_params[:date_created])
            subTotal = handle_params[:total_amount]
            deliveryFee = handle_params[:total_shipping]
            total = handle_params[:total_amount_with_shipping]
            total_shipping = handle_params[:total_shipping]
            parse  = {
                externalCode: handle_params[:id].to_s,
                storeId: handle_params[:store_id],
                subTotal: '%.2f' % subTotal,
                deliveryFee: '%.2f' % deliveryFee,
                total: '%.2f' % total,
                country: handle_params[:shipping][:receiver_address][:country][:id],
                state: STATES[handle_params[:shipping][:receiver_address][:state][:name].to_sym],
                total_shipping: '%.2f' % total_shipping,
                city: handle_params[:shipping][:receiver_address][:city][:name],
                district: handle_params[:shipping][:receiver_address][:neighborhood][:name],
                street: handle_params[:shipping][:receiver_address][:street_name],
                complement: handle_params[:shipping][:receiver_address][:comment],
                latitude: handle_params[:shipping][:receiver_address][:latitude],
                longitude: handle_params[:shipping][:receiver_address][:longitude],
                dtOrderCreate: created_at.new_offset("+00:00").strftime("%Y-%m-%dT%H:%M:%S.%LZ"),
                postalCode: handle_params[:shipping][:receiver_address][:zip_code],
                number: handle_params[:shipping][:receiver_address][:street_number],
                customer: {
                    externalCode: handle_params[:buyer][:id].to_s,
                    name: handle_params[:buyer][:nickname],
                    email:  handle_params[:buyer][:email],
                    contact:  handle_params[:buyer][:phone][:area_code].to_s + handle_params[:buyer][:phone][:number],
                },
                items: [],
                payments: []
            }

            for item in handle_params[:order_items]
                parse[:items].append({
                    externalCode: item[:item][:id],
                    name: item[:item][:title],
                    price: item[:unit_price],
                    quantity: item[:quantity],
                    total: item[:full_unit_price],
                    subItems: []
                })
            end

            for payment in handle_params[:payments]
                parse[:payments].append({
                    type: payment[:payment_type],
                    value: payment[:total_paid_amount]
                })
            end

            header = {
                'X-Sent': DateTime.now.new_offset("+00:00").strftime("%Hh%M - %d/%m/%y"),
                'Content-Type': 'application/json'
            }

            url = URI.parse('https://delivery-center-recruitment-ap.herokuapp.com/')

            # Create the HTTP objects
            http = Net::HTTP.new(url.host, url.port)
            http.use_ssl = true
            request = Net::HTTP::Post.new(url.request_uri, header)
            request.body = parse.to_json

            # Send the request
            response = http.request(request)

            ret = {
                message: response.message
            }

            render json: ret, status: response.code
        rescue StandardError => e
            print e
        end

        private
        def handle_params
            params.permit!
        end
    end
end
