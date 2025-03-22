import logs_threatment
from RabbitLibrary.rabbit_context import RabbitMQ


user_uuid=logs_threatment.main()[0]
message=logs_threatment.main()[1]
rabbitmq = RabbitMQ()

message = f'{message}|{user_uuid}'
rabbitmq.publish('authentication',message)
rabbitmq.close()