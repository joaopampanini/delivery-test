require 'net/http'

module Api
    class OrdersController < ActionController::API
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
            created_at = DateTime.parse(handle_params[0])
            subTotal = handle_params[1]
            deliveryFee = handle_params[2]
            total = handle_params[3]
            total_shipping = handle_params[2]
            parse  = {
                externalCode: handle_params[4].to_s,
                storeId: handle_params[5],
                subTotal: '%.2f' % subTotal,
                deliveryFee: '%.2f' % deliveryFee,
                total: '%.2f' % total,
                country: handle_params[6][:receiver_address][:country][:id],
                state: STATES[handle_params[6][:receiver_address][:state][:name].to_sym],
                total_shipping: '%.2f' % total_shipping,
                city: handle_params[6][:receiver_address][:city][:name],
                district: handle_params[6][:receiver_address][:neighborhood][:name],
                street: handle_params[6][:receiver_address][:street_name],
                complement: handle_params[6][:receiver_address][:comment],
                latitude: handle_params[6][:receiver_address][:latitude],
                longitude: handle_params[6][:receiver_address][:longitude],
                dtOrderCreate: created_at.new_offset("+00:00").strftime("%Y-%m-%dT%H:%M:%S.%LZ"),
                postalCode: handle_params[6][:receiver_address][:zip_code],
                number: handle_params[6][:receiver_address][:street_number],
                customer: {
                    externalCode: handle_params[7][:id].to_s,
                    name: handle_params[7][:nickname],
                    email:  handle_params[7][:email],
                    contact:  handle_params[7][:phone][:area_code].to_s + handle_params[7][:phone][:number],
                },
                items: [],
                payments: []
            }

            for item in handle_params[8]
                parse[:items].append({
                    externalCode: item[:item][:id],
                    name: item[:item][:title],
                    price: item[:unit_price],
                    quantity: item[:quantity],
                    total: item[:full_unit_price],
                    subItems: []
                })
            end

            for payment in handle_params[9]
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
            ret = {
                message: e
            }

            render json: ret, status: 400
        end

        private
        def handle_params
            params.require([
                :date_created,
                :total_amount,
                :total_shipping,
                :total_amount_with_shipping,
                :id,
                :store_id,
                :shipping,
                :buyer,
                :order_items,
                :payments
            ])
        end
    end
end
