library(tidyverse)
library(sf)
library(ggmap)
library(broom)
library(RColorBrewer)
library(ggsn)
library(viridis)
library(leaflet)
library(mapview)

setwd("/Users/sxs/Dropbox/Data Science/Spatial Data/")

# ASSIGNMENT FILE -----
# Counties shapefile
counties <- st_read("gz_2010_us_050_00_20m/gz_2010_us_050_00_20m.shp")
plot(st_geometry(counties))
head(counties)
names(counties)

# Remove Hawaii, Alaska, and Puerto Rico
counties <- counties %>%
  mutate(STATE = as.character(as.numeric(as.character(STATE)))) %>%
  filter(! STATE %in% c("02", "15", "72"))

st_crs(counties)  # EPSG: 4260

# we want to transform so it's the same as...

counties.reproj <- counties %>% st_transform(4326)
head(counties.reproj)

saveRDS(counties.reproj, "uscounties_2010.rds")
counties <- readRDS("uscounties_2010.rds")

# obesity data
obe <- read.csv("county_obesity_prev.csv")
obe <- mutate(obe, age.adjusted.percent = as.numeric(as.character(age.adjusted.percent)))

# merging the data
counties <- counties %>%
  mutate(fips.code = paste0(STATE, COUNTY))

counties <- merge(counties, obe, by = "fips.code")


pal_fun <- colorNumeric("BuPu", NULL)

leaflet(counties) %>%
  addPolygons(stroke = FALSE, fillColor = ~pal_fun(age.adjusted.percent),
              fillOpacity = 0.5, smoothFactor = 0.5) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addLegend("bottomright",  # location
            pal=pal_fun,    # palette function
            values=~age.adjusted.percent,  # value to be passed to palette function
            title = 'Poverty rate', # legend title
            opacity = 1)  %>%
  addScaleBar()

# -----------------------------------------------------------------------------
# 1. Spatial data types and mapping with the plot function
# -----------------------------------------------------------------------------
# Example of lines data ----

# We can download the zipped shapefile directly from the OpenDataPhilly website [https://www.opendataphilly.org/dataset/bike-network]

dir.create("bike_network")  # create directory (folder) to store our shapefile
setwd("bike_network")  # navigate to the bike_network directory
download.file("http://data.phl.opendata.arcgis.com/datasets/b5f660b9f0f44ced915995b6d49f6385_0.zip",
              "bike_network.zip")  # download zipped shapefile from OpenDataPhilly
unzip("bike_network.zip")  # unzip the file
if (file.exists("bike_network.zip")) file.remove("bike_network.zip")

# Let's start by working with the shapefile in the sp framework
library(sp)
library(rgdal)

setwd("..")  # go back to parent folder (good practice so you can easily find 
             # output later)
bn.sp <- readOGR(dsn="bike_network", layer="Bike_Network")
class(bn.sp)  # bn.sp is a SpatialLinesDataFrame
plot(bn.sp)  # sp objects can be mapped directly using the base plot command
str(bn.sp, max.level=2)  # max.level makes read-out more manageable
head(bn.sp@data)  # data attributes stored in data slot in data.frame form
str(bn.sp@lines, max.level = 2, list.len = 10)  # geometry attributes stored in lines slot
                                                # list.len sets number of list elements to display
bn.sp@lines[[1]]  # double brackets access the first line of the lines slot
bn.sp@lines[[2]]  # geometry attributes of the second line
bn@data[1:2,]  # these lines correspond to segments of Spring Garden Street
bn.sp@bbox  # boundaries stored in bbox slot (bbox = bounding box)

# Now, let's compare the above to handling spatial data in the sf framework
bnsf <- st_read("bike_network/Bike_Network.shp")
class(bnsf)  # of class sf and data.frame
# sf objects can be handled like data frames using familiar commands
str(bnsf)
head(bnsf)  
dim(bnsf)
bnsf[1,]  
head(bnsf$STREETNAME)  
head(bnsf[,3])

# Spatial attributes of sf objects can be accessed with the st_geometry command
bn.geo <- st_geometry(bnsf)
bn.att <- st_att(bnsf)
plot(bn.geo)
bn.geo[[1]]  # line segment 1 
bn.geo[[2]]  # line segment 2
bnsf[1:2,]

# dplyr commands can be used to manipulate sf objects
bnsf.spruce <- filter(bnsf, STREETNAME == "SPRUCE  ST")
bnsf.walnut <- filter(bnsf, STREETNAME == "WALNUT  ST")
plot(bn.geo)
plot(st_geometry(bnsf.spruce), col="red", lwd=3, add=TRUE)
plot(st_geometry(bnsf.walnut), col="blue", lwd=3, add=TRUE)

# Example of points data ----
#ci.raw <- read.csv("incidents_part1_part2.csv")
#ci.data <- ci.raw %>%
#  select(lng, lat, location_block, dispatch_date, dispatch_time, text_general_code) %>%
#  filter(! is.na(lng)) %>%
#  mutate(dispatch_date = as.Date(dispatch_date)) %>%
#  rename(longitude = lng, latitude = lat, offense_type = text_general_code) %>%
#  filter(dispatch_date > as.Date("2017-12-31"))

#dim(ci.data)[1]  # 125,326
#ci.data2 <- filter(ci.data, dispatch_date > as.Date("2018-08-31")  # filter for Sep 2018
#                   & dispatch_date < as.Date("2018-10-01"))
#dim(ci.data2)[1]  # 13,767

#xy <- ci.data2[c("longitude", "latitude")]
#ci <- SpatialPointsDataFrame(coords = xy, data = ci.data2, 
#                             proj4string = CRS("+proj=longlat +datum=WGS84 
#                                               +ellps=WGS84 +towgs84=0,0,0"))
#ci <- st_as_sf(ci)

saveRDS(ci, "crime_incidents.rds")

ci <- readRDS("crime_incidents.rds")
head(ci)  # Note geometry type is POINT
str(ci)
summary(ci$dispatch_date)  # crime incidents in September 2018
table(ci$offense_type)  # take a look at the offense types
# take a look at spatial attributes
st_geometry(ci)

# dplyr commands can be used to filter by offense_type...
ci.gun.assault <- filter(ci, offense_type == "Aggravated Assault Firearm")
head(ci.gun.assault)  
plot(st_geometry(ci.gun.assault))

ci.hom <- dplyr::filter(ci, offense_type == "Homicide - Criminal")
crime$dispatch_date <- as.factor(crime$dispatch_date)

setwd("/Users/sxs/Dropbox/Data Science/BMIN503/DataFiles")
# Reformat date back to factor...
crime <- readRDS("crime_incidents.rds")
crime$dispatch_date <- as.factor(crime$dispatch_date)
saveRDS(crime, "crime_incidents.rds")

# Example of polygon data ----
setwd("/Users/sxs/Dropbox/Data Science/Spatial Data/")
ct.sp <- readOGR(dsn="PhiladelphiaCensusTracts2010", layer="Census_Tracts_2010")
saveRDS(ct.sp, "philadelphia_tracts_2010_sp.rds")
ct.df <- fortify(ct.sp, region = "GEOID10")
ct.df <- rename(ct.df, GEOID10 = id, lon = long)
head(ct.df)
ct.df <- merge(ct.df, percent_poverty, by = "GEOID10")
#ct <- st_as_sf(ct)
#saveRDS(ct, "philadelphia_tracts.rds")

ct <- readRDS("philadelphia_tracts.rds")
head(ct)
plot(st_geometry(ct))
plot(st_geometry(ct), col = "lemonchiffon2")
ci.hom <- filter(ci, offense_type == "Homicide - Criminal")
plot(st_geometry(ci.hom), col="firebrick2", add = TRUE, cex = 2.5, pch=16)

# Layering maps
plot(ct, col="lightgrey")
plot(bn, add=TRUE, col="green", lwd=2)
plot()


# Example of raster data ----
library(datasets)
volcano  # volcano is a matrix 
filled.contour(volcano, color = terrain.colors, asp = 1)

# -----------------------------------------------------------------------------
# 2. Making polished maps with ggplot2 and ggmap
# -----------------------------------------------------------------------------

# ggplot2 ----
ggplot(ct) +
  geom_sf()

ggplot(ci.hom) +
  geom_sf()

ggplot() + 
  geom_sf(data = ct) +
  geom_sf(data = ci.hom)

ggplot(ct.pov) +
  geom_sf(aes(fill = percent.poverty))

ggplot(ct.pov) +
  geom_sf(aes(fill = percent.poverty, col=percent.poverty)) 
  
myPalette <- colorRampPalette(brewer.pal(9, "BuPu"))

tmp <- ggplot(ct.pov) +
  geom_sf(aes(fill = percent.poverty)) +
  theme_minimal() +
  blank() +
  scale_fill_gradientn(name = "Percent Poverty (%)",
                       colours = myPalette(100)) +
  north(x.min = -75.28031, y.min = 39.86747, x.max = -74.95575, 
        y.max = 40.13793, location = "bottomright", 
        symbol=12)

addScaleBar(tmp, ct.pov, "zinc", addParams = list(noBins = 5))

pdf("percentpoverty.pdf", height=12, width=8)
ggplot(ct.pov) +
  geom_sf(aes(fill = percent.poverty)) +
  geom_sf(data = ci.hom, color = "gold", size = 4) +
  theme_minimal() +
  theme(axis.line = element_blank(), 
        axis.text = element_blank(),
        axis.title = element_blank(),
        panel.grid = element_line(color = "white"),
        legend.key.size = unit(1, "cm"), 
        legend.text = element_text(size = 16),
        legend.title = element_text(size = 16)) +
  scale_fill_gradientn(name = "Percent \npoverty (%)",
                     colours = myPalette(100)) #+
#  north(x.min = -75.28031, y.min = 39.86747, x.max = -74.95575, 
#        y.max = 40.13793, location = "bottomright", 
#        symbol=12, anchor = c(x = -75, y = 39.9)) +
#  scalebar(x.min = -75.28031, y.min = 39.86747, x.max = -74.95575, 
#           y.max = 40.13793, dist = 5, dd2km = TRUE, model = "WGS84")
dev.off()

makeNiceNumber = function(num, num.pretty = 1) {
  # Rounding provided by code from Maarten Plieger
  return((round(num/10^(round(log10(num))-1))*(10^(round(log10(num))-1))))
}

createBoxPolygon = function(llcorner, width, height) {
  relativeCoords = data.frame(c(0, 0, width, width, 0), c(0, height, height, 0, 0))
  names(relativeCoords) = names(llcorner)
  return(t(apply(relativeCoords, 1, function(x) llcorner + x)))
}

addScaleBar = function(ggplot_obj, spatial_obj, attribute, addParams = 
                         list()) {
  addParamsDefaults = list(noBins = 5, xname = "x", yname = "y", unit = "m", 
                           placement = "bottomright", sbLengthPct = 0.3, sbHeightvsWidth = 1/14)
  addParams = modifyList(addParamsDefaults, addParams)
  
  range_x = max(spatial_obj[[addParams[["xname"]]]]) - min(spatial_obj[[addParams[["xname"]]]])
  range_y = max(spatial_obj[[addParams[["yname"]]]]) -  min(spatial_obj[[addParams[["yname"]]]])
  lengthScalebar = addParams[["sbLengthPct"]] * range_x
  ## OPTION: use pretty() instead
  widthBin = makeNiceNumber(lengthScalebar / addParams[["noBins"]])
  heightBin = lengthScalebar * addParams[["sbHeightvsWidth"]]
  lowerLeftCornerScaleBar = c(x = max(spatial_obj[[addParams[["xname"]]]]) - (widthBin * addParams[["noBins"]]), y = min(spatial_obj[[addParams[["yname"]]]]))
  scaleBarPolygon = do.call("rbind", lapply(0:(addParams[["noBins"]] - 1), function(n) {
    dum = data.frame(createBoxPolygon(lowerLeftCornerScaleBar + c((n * widthBin), 0), widthBin, heightBin))
    if(!(n + 1) %% 2 == 0) dum$cat = "odd" else dum$cat = "even"
    return(dum)
  }))
  scaleBarPolygon[[attribute]] = min(spatial_obj[[attribute]])
  textScaleBar = data.frame(x = lowerLeftCornerScaleBar[[addParams[["xname"]]]] + (c(0:(addParams[["noBins"]])) * widthBin), y = lowerLeftCornerScaleBar[[addParams[["yname"]]]],
                            label = as.character(0:(addParams[["noBins"]]) * widthBin))
  textScaleBar[[attribute]] = min(spatial_obj[[attribute]])
  
  return(ggplot_obj +
           geom_polygon(data = subset(scaleBarPolygon, cat == "odd"), fill = "black", color = "black", legend = FALSE) +
           geom_polygon(data = subset(scaleBarPolygon, cat == "even"), fill = "white", color = "black", legend = FALSE) +
           geom_text(aes(label = label), color = "black", size = 6, data = textScaleBar, hjust = 0.5, vjust = 1.2, legend = FALSE))
}
# ggmap ----

library(ggmap)
if(!requireNamespace("devtools")) install.packages("devtools")
devtools::install_github("dkahle/ggmap", ref = "tidyup")

# Get API key froom Google: https://developers.google.com/places/web-service/get-api-key
register_google("AIzaSyBrwTLG8vz3RPeoVUrM4e6wcWMGOimtTrs")

philly.map <- qmap("Philadelphia", zoom = 11)
philly.toner <- qmap("19133", maptype = "toner-lite", zoom = 11)
philly.sat <- qmap("19133", maptype = "satellite", zoom = 11)
philly.tl <- qmap("19133", source="stamen", zoom=11, maptype="terrain")
philly.tl <- qmap("19133", source="stamen", zoom=11, maptype="terrain-lines")
philly.wc <- qmap("19133", source="stamen", zoom=11, maptype="watercolor")

philly.sat + 
  geom_point(data = ci.hom, aes(x = longitude, y = latitude),
             color = "firebrick3", size = 4)

philly.toner + 
  geom_polygon(data = ct.df, aes(x = lon, y = lat, group = group, 
                                 fill = percent.poverty, alpha = 0.5)) +
  theme(legend.key.size = unit(1, "cm"), 
        legend.text = element_text(size = 16),
        legend.title = element_text(size = 16)) +
  scale_fill_gradientn(name = "Poverty \nrate (%)",
                       colours = myPalette(100))

ggplot(data = ct.df) +
  geom_polygon(aes(x = lon, y = lat, group = group))
library(mapview)  
  
  
mapview(ct.pov) +
  geom_sf(data = ct.pov, aes(fill="percent.poverty"))

ct.df <- lef

pp <- ggplot() +
  geom_sf(data = ct.pov, aes(fill = percent.poverty)) +
  geom_sf(data = ci.hom, color = "gold", size = 4) +
  theme_minimal() +
  theme(axis.line = element_blank(), 
        axis.text = element_blank(),
        axis.title = element_blank(),
        panel.grid = element_line(color = "white"),
        legend.key.size = unit(1, "cm"), 
        legend.text = element_text(size = 16),
        legend.title = element_text(size = 16)) +
  scale_fill_gradientn(name = "Percent \npoverty (%)",
                       colours = myPalette(100))

# Harnesses the power of GoogleMaps, so location data can be understood in a 
# number of ways:
# - Geocoordinates (this is a format that ggplot2 understands): ...
# - Address: 421 Curie Boulevard, Philadelphia, PA, 19104 (or 421 curie blvd philly)
# - Name: Biomedical Research Building, Philadelphia, PA

# leaflet (good tutorial: https://cengel.github.io/rspatial/4_Mapping.nb.html#web-mapping-with-leaflet)----
library(mapview)
mapview(ci.hom)
mapview(ct.pov, zcol=c("percent.poverty"), legend = TRUE)

pal_fun <- colorNumeric("BuPu", NULL)
#pal_fun <- colorQuantile("BuPu", NULL, probs = seq(0, 1, length.out = 6))

pu_message <- paste0(ct.pov$NAMELSAD10, "<br>Poverty rate: ", 
                  round(ct.pov$percent.poverty,1), "%")

leaflet(ct.pov) %>%
  addPolygons(stroke = FALSE,  # remove polygon borders
              fillColor = ~pal_fun(percent.poverty),
              fillOpacity = 0.5, smoothFactor = 0.5,
              popup = p_popup) %>%
  addTiles() 

leaflet(ct.pov) %>%
  addPolygons(stroke = FALSE,  # remove polygon borders
              fillColor = ~pal_fun(percent.poverty),
              fillOpacity = 0.5, smoothFactor = 0.5,
              popup = p_popup) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addLegend("bottomright",  # location
            pal=pal_fun,    # palette function
            values=~percent.poverty,  # value to be passed to palette function
            title = 'Poverty rate', # legend title
            opacity = 1)  %>%
  addScaleBar()


# -----------------------------------------------------------------------------
# 3. Acquiring and mapping Census data
# -----------------------------------------------------------------------------

# Get Census data through an API (tidycensus) ----
# To get a Census API key:
# 1. Go to https://www.census.gov/developers/
# 2. Click on the Request a KEY box on the left side of the page.
# 3. Fill out the pop-up window form.
# 4. You will receive an email with your key code in the message.
library(tidyverse)
library(tidycensus)

census_api_key("YOUR API KEY GOES HERE", install=TRUE)
census_api_key("e2b194657be061e1296c7b74cc5e6552cd1a071c", install=TRUE)
readRenviron("~/.Renviron")



# tidy census public transportation example ----

pt <- load_variables(geography = "csa", 2016, "acs1")

public.trans <- get_acs(geography = "metropolitan statistical area/micropolitan statistical area", 
        variables = "DP03_0021PE",  
        summary_var = "B01003_001", 
        survey = "acs1", 
        year = 2016) 
head(public.trans)

public.trans %>%
  filter(summary_est > 2e6) %>%  # Filter MSA's for those with population >2MIL
  mutate(NAME = gsub("Metro Area", "", NAME)) %>%
  ggplot(aes(x = estimate, y = reorder(NAME, estimate))) + 
  geom_point(color = "navy", size = 2.5) + 
  labs(title = "Percentage of residents who take public transportation to work", 
       subtitle = "2016 1-year ACS estimates", 
       y = "", 
       x = "ACS estimate (percent)", 
       caption = "Source: ACS Data Profile variable DP03_0021P via the tidycensus R package")

v15 <- load_variables(2016, "acs5", cache=TRUE)
View(v15)
v15.pov <- filter(v15, grepl("POVERTY", concept))
View(v15.pov)
poverty.vars <- filter(v15, name %in% c("B17010_001", "B17010_002"))
paste(poverty.vars$label)
paste(poverty.vars$concept)

# Let's get median income estimates for all census tracts in Philadelphia for ----
# the ACS 2012-2016 5-year estimates ----
#

ct.pov <- merge(ct, percent_poverty, by = "GEOID10")

library(viridis)
ggplot() + 
  geom_sf(data = ct.pov, aes(fill=percent.poverty, color=pp)) +
  geom_sf(data = ci.hom, aes()) +
  scale_fill_viridis(option = "magma") + 
  scale_color_viridis(option = "magma") +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank()) +
  north(map) 

med.income <- get_acs(geography = "tract", variables = "B19326_001", 
                      state = "PA", county = "Philadelphia")
med.income <- rename(med.income, med.income = estimate, GEOID10 = GEOID)
ct2 <- left_join(ct, med.income[, c("GEOID10", "med.income")], by = "GEOID10")
ctdf <- left_join(ctdf, med.income[, c("GEOID10", "med.income")], by = "GEOID10")
ggplot(data=ctdf, aes(x=long, y=lat, group=id, fill=med.income)) +
  geom_polygon() +
  theme_nothing(legend = TRUE)




