from flask import Flask, request, make_response, jsonify
from flask_restful import Api, Resource
from chatbot import Leadie, Leadie2

app = Flask(__name__)
api = Api(app)

class LeadieApp(Resource):
    def __init__(self):
        super().__init__()
        self.leadie = Leadie2()

    def post(self):
        # print(request.data)
        # print(type(request.data))
        if request.is_json:
            requestData = request.get_json()

            queries = requestData['query']

            if queries:

                response_body = {'response': self.leadie.get_leadie_response(queries)}

                res = make_response(jsonify(response_body),201)

                return res

            else:
                # print("Incorrect data")
                return make_response(jsonify({"response": "Invalid JSON data"}), 400)

        else:
            # print("Incorrect format")
            return make_response(jsonify({"response": "Request must be JSON"}),400)

api.add_resource(LeadieApp, '/')


if __name__ == '__main__':
    app.run(debug=False)