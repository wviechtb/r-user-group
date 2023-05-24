#### Florentine Exploration ####
# Tony Hung

#### Install Packages #### 
# Comment out a section by highlighting it, and then cmd+shift+c
# install.packages("igraph")
# install.packages("ergm")
# install.packages("network")
# install.packages("intergraph")
# install.packages("scales")

#### Setting Up the Script####
library(ergm) # load ergm into the environment

data("florentine") # we are getting the florentine networks that are in the ergm package
?"florentine" # tells you a bit more about the Florentine dataset

detach(package:ergm)
detach(package:network)
require(intergraph)
require(igraph)

flo_m<-asIgraph(flomarriage) # converting the flomarriage from a Networks object into an Igraph object
flo_b<-asIgraph(flobusiness) # converting the flobusiness from a Networks object into an Igraph object

is.directed(flo_m) # checks if the graph is directed or not
is.directed(flo_b)

is.weighted(flo_m) # checks if the graph is weighted or not
is.weighted(flo_b)

summary(flo_b) # gives a summary of the network: number of nodes + edges, what kind of attributes it has
summary(flo_m)
# Copied from the package documentation: (1) "wealth" each family's net wealth in 1427 (in thousands of lira); (2) "priorates" the number of priorates (seats on the civic council) held between 1282- 1344; and (3) "totalties" the total number of business or marriage ties in the total dataset of 116 families

#### Plotting the networks ####

plot(flo_m) #rather ugly
plot(flo_b)

# making it prettier
par(mfrow = c(1, 2)) # plotting it side by side
plot.igraph(flo_b,vertex.color="darkorange",vertex.frame.color="white",edge.color="darkgrey",edge.width=2,vertex.label.family="sans",vertex.label=V(flo_b)$vertex.names,main="Florentine Business Network", layout = layout_nicely)
plot.igraph(flo_m,vertex.color="darkorange",vertex.frame.color="white",edge.color="darkgrey",edge.width=2,vertex.label.family="sans",vertex.label=V(flo_m)$vertex.names,main="Florentine Marriage Network", layout = layout_nicely)

par(mfrow = c(1, 1)) # reset plotting layout

# plot.igraph(flo_m,edge.arrow.size=0,vertex.color=degree(flo_m),vertex.frame.color="white",edge.color="darkgrey",edge.width=2,vertex.label.family="sans",vertex.label=V(flo_m)$vertex.names,main="Florentine Marriage Network")

#### Basic Network Descriptions ####
# Note: you can easily swap this out with flo_m!

vcount(flo_b) # gives the number of nodes in the network
gorder(flo_b) # another way to see how many nodes there are

ecount(flo_b) # gives the number of edges in the network
gsize(flo_b) # another way to see how many edges there are

## Density: the number of actual links divided by the number of potential links
edge_density(flo_b) # calculating the density of the network. So this means that 12.5% of the possible total edges are present in this network

## Path Length: calculates the length of all the shortest paths from or to the vertices in the network

dist_flo_b = distances(flo_b) # it gives a matrix/table
colnames(dist_flo_b) = rownames(dist_flo_b) = V(flo_b)$vertex.names # putting in names so you can actually read the table a bit better... The Inf means that there's no possible connection. If you look at the graph, you can see that there are a lot of isolates in this network. 
head(dist_flo_b)

## Average Path Length: the average geodesic paths between all pairs of nodes
apl_flo_b = mean_distance(flo_b,unconnected=T) # this means that on average, the shortest path between nodes are 2.38 steps in the entire network.
apl_flo_b1 = average.path.length(flo_b,unconnected=T) # same thing but different function.

apl_flo_b_vector =  rowMeans(dist_flo_b) # this gives you the vector of average path lengths for each node. As you can see it doesn't really work over here because we have a disconnected graph.

## Diameter: the longest shortest path
diam_flo_b = diameter(flo_b) # this means that the highest geodesic path is 5 steps.

#### Network Descriptives / Structures (unweighted, undirected) ####

## Degree Centrality: the number of edges each node has
deg_flo_b = degree(flo_b) # degree centrality for each node in the flo_b network
mean(deg_flo_b) # average degree centrality in the flo_b network

## Closeness Centrality: measures the average distance to all other vertices. The higher the closer.
clos_flo_b = closeness(flo_b) # as you can see, because there are isolates in the graph, closeness is not that well-defined
max(clos_flo_b) 

## Betweenness centrality: measures how often a node lies on the geodesic path between other nodes. Implies brokerage. The higher, the more in between nodes.
bet_flo_b = betweenness(flo_b)

## Eigenvector centrality: measures the type of connections you have. If you have a lot of powerful/important connections, then this means that you are more important.The higher the better.
eigen_flo_b = eigen_centrality(flo_b)$vector

## Assortativity/homophily: measures how nodes will connect with each other based on a characteristic. Should interpret these values just like correlation

# In the business network, we have the wealth attribute. The wealth attribute gives each family's net wealth in 1427.
assortativity(flo_b,types1=V(flo_b)$wealth) # The Console returns -0.2, which means that wealth and is negatively correlated to how families connect. This also means that in terms of wealth, there is some dissortativity (as represented by the negative values). What can this possibly tell us? Perhaps business relationships are not built on top of how wealthy each family is... 

# Let's try other attributes
assortativity(flo_b,types1=V(flo_b)$priorates) 
assortativity(flo_b,types1=V(flo_b)$totalties)
# All rather negative.

## Transitivity/clustering/cliquishness: measures whether a node is embedded in a tightly knit group of clique, of other nodes.

# local transitivity: gives you the transitivity per node
loc_trans_flo_b = transitivity(flo_b,type="local")

# global transitivity: gives you the overall transitivity
glo_trans_flo_b = transitivity(flo_b,type="global") 

# Whew, we've surely made a lot of different metrics in this script. Let's make a table and compare them!

families = V(flo_b)$vertex.names # extracting the list of names from the network and save it as a variable

flo_b_stats = cbind(families,deg_flo_b,apl_flo_b_vector,clos_flo_b,loc_trans_flo_b,bet_flo_b,eigen_flo_b)
colnames(flo_b_stats) = c("Florentine Families","Degree Centrality","Average Path Length per Node","Closeness Centrality","Local Transitivity","Betweenness Centrality","Eigenvector Centrality") # As you can see, the isolates are REALLY messing up some of the things we would like to know about...
View(flo_b_stats)

#### Extension: Removing Isolates ####

# As we have seen in the business network, keeping the isolates really do mess things up. This is especially the case for determining closeness.  
flo_b_no_i = delete.vertices(flo_b, degree(flo_b)==0)
summary(flo_b_no_i)

# Let's plot it.
plot.igraph(flo_b_no_i,vertex.color="darkorange",vertex.frame.color="white",edge.color="darkgrey",edge.width=2,vertex.label.family="sans",vertex.label=V(flo_b_no_i)$vertex.names,main="Florentine Business Network No Isolates", layout = layout_nicely)

# So then let's make another table with the same metrics as from the above section and see perhaps things have improved...

flo_b_stats_i_removed = as.data.frame(cbind(V(flo_b_no_i)$vertex.names,degree(flo_b_no_i),rowMeans(distances(flo_b_no_i)),closeness(flo_b_no_i),transitivity(flo_b_no_i,type="local"),betweenness(flo_b_no_i),eigen_centrality(flo_b_no_i)$vector))
colnames(flo_b_stats_i_removed) = c("Florentine Families","Degree Centrality","Average Path Length per Node","Closeness Centrality","Local Transitivity","Betweenness Centrality","Eigenvector Centrality")
View(flo_b_stats_i_removed)

# See anything surprising about this? We see that there is NaN for the local transitivity of Pazzi, Salviati, and Tournabuori. Is this surprising? No. Transitivity measures triads. All three of those families are only dyads, with their only connection being the Medici family. Transitivity postulates that if i <-> j, and j <-> k, then i <-> k.

# If you would like to explore this more, what would you do? I probably would:
# 1. Repeat the above steps for the marriage network
# 2. Combine both graphs somehow and analyze it together as one network

#### Good to know ####

# Converting to Adjacency Matrix + Edge List
adj_flo_b = as.matrix(get.adjacency(flo_b)) # Converts the network into an adjacency matrix
adj_flo_b1 = as.matrix(as_adj(flo_b)) # Converts the network into an adjacency matrix

el_flo_b = get.edgelist(flo_b) # Converts the network into an edge list
el_flo_b1 = as_edgelist(flo_b) # Converts the network into an edge list

