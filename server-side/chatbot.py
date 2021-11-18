import json

from pymongo import MongoClient
from chatterbot import ChatBot
from chatterbot.trainers import ListTrainer
from chatterbot.trainers import ChatterBotCorpusTrainer
from chatterbot.response_selection import get_most_frequent_response, get_first_response
from chatterbot.comparisons import LevenshteinDistance
from dotenv import load_dotenv
import adapter
import os
import re

load_dotenv()

class Leadie:
    def __init__(self):
        client = MongoClient(os.environ.get("MONGOGB_CONNECT_STRING"))
        db = client.get_database('courses_db')
        records = db.course_info
        data = list(records.find({},{"_id":0, "categories":0,}))

        #print(data)

        self.courses = {}
        for k, course in enumerate(data):
            answers = course["answer"].split("#")
            self.courses[course["question"]] = answers

        self.bot = ChatBot(
        'Leadie',
        storage_adapter='chatterbot.storage.MongoDatabaseAdapter',
        logic_adapters=[
            {
                'import_path': 'chatterbot.logic.BestMatch',
                'default_response': 'I am sorry, but I do not understand.',
                'maximum_similarity_threshold': 0.90
            },
            #'chatterbot.logic.BestMatch',
            'chatterbot.logic.MathematicalEvaluation',
            #'chatterbot.logic.TimeLogicAdapter'
        ],
        database_uri=os.environ.get("MONGODB_CONNECT_STRING"),
        response_selection_method=get_first_response
        )

    def train(self, trainDataList):
        trainer = ListTrainer(self.bot)
        trainer.train(trainDataList)



# trainer = ListTrainer(bot)
# trainer.train([
#     "How are you?",
#     "I am good.",
#     "That is good to hear.",
#     "Thank you",
#     "You are welcome.",
# ])
#
# trainer.train([
#     "What is",
#     "0",
#     "Is major or elective",
#     "1",
#     "Any prerequisite for",
#     "2"
#     "Which semester offers",
#     "3",
#     "Describe",
#     "4",
# ])

    def get_leadie_response(self, queries):
        queriesCode = ""
        queriesQuestion = ""
        #print(queries)
        # while True:
        try:
            # queries = input("You: ")
            bot_input = ""
            found = 0
            for course in self.courses.keys():
                found = queries.find(course)
                if found != -1:
                    queriesQuestion = queries.replace(course, "")
                    queriesCode = course
                    try:
                        if queriesQuestion == "":
                            raise ValueError
                        bot_input = self.courses[queriesCode][int(str(self.bot.get_response(queriesQuestion)))]
                    except ValueError:
                        # bot_input = bot.get_response(queries)
                        for i in range(len(self.courses[queriesCode])):
                            bot_input += self.courses[queriesCode][i]
                    break
            if found == -1:
                bot_input = self.bot.get_response(queries)
            # print("Leadie: ", end="")
            # print(bot_input)
            # print("\n")

            return str(bot_input)

        except(KeyboardInterrupt, EOFError, SystemExit):
            print("Leadie: Thank you for using me")


class Leadie2:
    def __init__(self):
        # print(os.environ)
        client = MongoClient(os.environ.get("MONGODB_CONNECT_STRING"))
        db = client.get_database('courses_db')
        self.records = db.course_info
        data = list(self.records.find({},{"_id":0, "categories":0, "answer":0}))

        #print(data)

        self.courses = []
        for course in data:
            # answers = course["answer"].split("#")
            self.courses.append(course['question'].lower())

        # print(self.courses)

        self.bot = ChatBot(
        'Leadie',
        storage_adapter='chatterbot.storage.MongoDatabaseAdapter',
        logic_adapters=[
            {
                'import_path': 'adapter.NewBestMatch',
                'default_response': 'I am sorry, but I do not understand.',
                'maximum_similarity_threshold': 0.90,
            },
            # {
            #     "import_path": "chatterbot.logic.BestMatch",
            #     "statement_comparison_function": LevenshteinDistance,
            #     "response_selection_method": get_most_frequent_response,
            # },
            # 'chatterbot.logic.BestMatch',
            #'chatterbot.logic.MathematicalEvaluation',
            #'chatterbot.logic.TimeLogicAdapter'
        ],
        preprocessors=['chatterbot.preprocessors.clean_whitespace'],
        database_uri=os.environ.get("MONGODB_CONNECT_STRING"),
        response_selection_method=get_first_response,
        )

    def train(self, trainDataList):
        trainer = ListTrainer(self.bot)
        trainer.train(trainDataList)



# trainer = ListTrainer(bot)
# trainer.train([
#     "How are you?",
#     "I am good.",
#     "That is good to hear.",
#     "Thank you",
#     "You are welcome.",
# ])
#
# trainer.train([
#     "What is",
#     "0",
#     "Is major or elective",
#     "1",
#     "Any prerequisite for",
#     "2"
#     "Which semester offers",
#     "3",
#     "Describe",
#     "4",
# ])

    def get_leadie_response(self, queries):
        queriesCode = ""
        queriesQuestion = ""
        queries_lwr = re.sub(r'[^\w\s]', '', queries).lower()
        print(queries_lwr)
        #print(queries)
        # while True:
        try:
            # queries = input("You: ")
            bot_input = ""
            found = 0
            for course in self.courses:
                found = queries_lwr.find(course)
                if found != -1:
                    queriesQuestion = queries_lwr.replace(course, "").strip()
                    # print(queriesQuestion, len(queriesQuestion))
                    queriesCode = course
                    data = list(
                        self.records.find({"question": queriesCode.upper()}, {"_id": 0, "categories": 0, "question": 0}))
                    # print(queriesCode.upper())
                    # print(data)
                    coursesData = data[0]['answer'].split("#")
                    try:
                        if queriesQuestion == "":
                            raise ValueError
                        bot_input = coursesData[int(str(self.bot.get_response(queriesQuestion)))]
                    except ValueError:
                        # bot_input = bot.get_response(queries)

                        for info in coursesData:
                            bot_input += info
                    break
            if found == -1:
                bot_input = self.bot.get_response(queries_lwr)
            # print("Leadie: ", end="")
            # print(bot_input)
            # print("\n")

            return str(bot_input)

        except(KeyboardInterrupt, EOFError, SystemExit):
            print("Leadie: Thank you for using me")