import logging

import azure.functions as func
from . import sum

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    
    val1 = int(req.params.get('val1'))
    val2 = int(req.params.get('val2'))

    add = req.params.get('add')
    if not add:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('add')

    if add:
        return func.HttpResponse(f"{add} of {val1} + {val2} = {sum.sum_numbers(val1,val2)}.")
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass add in the query string or in the request body for a personalized response.",
             status_code=200
        )