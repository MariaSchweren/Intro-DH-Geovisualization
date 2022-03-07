import pandas as pd
import ast

formatted = pd.read_csv("formatted.csv")
locations = pd.read_csv("locations.csv")
coordinates = pd.read_csv("coordinates.csv", sep=";")

for index, row in locations.iterrows():
    coords = coordinates.loc[(coordinates["location"] == row["location"]) | (coordinates["geo_name"] == row["location"])]
    coords = coords["coordinates"]
    split_ = str(coords.iloc[0]).split(",")
    locations.loc[index, "location_lat"] = split_[0]
    locations.loc[index, "location_lng"] = split_[1]
    route_lat = []
    route_lng = []
    route = ast.literal_eval(row["route"])
    if route:
        for route_stop in route:
            coords = coordinates.loc[(coordinates["location"] == route_stop) | (coordinates["geo_name"] == route_stop)]
            coords = coords["coordinates"]
            split_ = str(coords.iloc[0]).split(",")
            route_lat.append(split_[0])
            route_lng.append(split_[1])
        locations.loc[index, "route_lat"] = str(route_lat)
        locations.loc[index, "route_lng"] = str(route_lng)
locations.to_csv("locations.csv")
