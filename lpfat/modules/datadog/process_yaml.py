import sys
import json

f = open('python.log', 'w')
def log(*args):
    print(*args, file=f)

input = sys.stdin.read()
input_json = json.loads(input)

monitors = json.loads(input_json['monitors'])
tags = json.loads(input_json['tags'])

required_fields_for_query_contruction = [
    "name",
    "priority",
    "trigger",
    "period",
    "spaceagg",
    "timeagg",
    "message",
    "metric_math",
    "metric",
    "filters"
]

required_fields_for_direct_use = [
    "name",
    "priority",
    "query",
    "message",
    "type"
]


for monitor in monitors.keys():
    if not set(required_fields_for_direct_use).issubset(set(monitors[monitor].keys())):
        #Not all fields for direct use are present, so we need to construct the query, assuming that it is a metric alert.
        if not set(required_fields_for_query_contruction).issubset(set(monitors[monitor].keys())):
            sys.stderr.write(f"Error found while processing '{monitors[monitor]['name']}'. To construct a query the following parameters are required in the YAML: {required_fields_for_query_contruction}")
            exit(1)
        else:
            temp_math = monitors[monitor]['metric_math'].split(' ')
            for term in monitors[monitor]['metric'].keys():
                tmp_val = monitors[monitor]['metric'][term]
                tmp_val = f"{monitors[monitor]['spaceagg']}:{tmp_val}{{{monitors[monitor]['filters']}}}"  # add space aggreation and filters to metric

                if "multi" in monitors[monitor].keys():   #check if multi present, add
                    log(monitors[monitor]['multi'])
                    tmp_val = f"{tmp_val} by {{{monitors[monitor]['multi']}}}"

                if "function" in monitors[monitor].keys(): #check if function present, add
                    tmp_val = f"{tmp_val}.{monitors[monitor]['function']}"

                #substitute in the construct into the metric math field
                for i in range(0, len(temp_math)):
                    if temp_math[i] == term:
                        temp_math[i] = tmp_val

            # construct the query from its parts
            metric_math = ' '.join(temp_math)
            monitors[monitor]['query'] = f"{monitors[monitor]['timeagg']}(last_{monitors[monitor]['period']}):({metric_math}) {monitors[monitor]['trigger']}"
    
    #substitute in filter placeholders if they are present
    if 'leaseplan:workload' in tags.keys():
        monitors[monitor]['query'] = monitors[monitor]['query'].replace("lpworkload", tags['leaseplan:workload'])
    if 'leaseplan:environment' in tags.keys():
        monitors[monitor]['query'] = monitors[monitor]['query'].replace("lpenv", tags['leaseplan:environment'])
    if 'leaseplan:project' in tags.keys():
        monitors[monitor]['query'] = monitors[monitor]['query'].replace("lpproject", tags['leaseplan:project'])


output = dict()
output['monitors'] = json.dumps(monitors)
print(json.dumps(output))
exit(0)
