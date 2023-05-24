# Intro to Network Analysis. 
# Slide script.
# RUG@UM

library(igraph)

# The Most Basic Data Structures

# Adjacency Matrix
adj_m = matrix(data=c(0,1,1,1,0,1,0,1,0),nrow=3, ncol=3) # make some sort of adjacency matrix
colnames(adj_m) = c('Mark','Jane','Peter') # Naming the columns
rownames(adj_m) = c('Mark','Jane','Peter') # naming the rows

adj_d = graph.adjacency(adj_m) # Make it into an igraph object
plot(adj_d)

adj_u = graph.adjacency(adj_m, mode = "undirected") # You can also make it into an undirected graph
plot(adj_u)

# Edgelist
edge_l = matrix(data=c('Dave','Anna','Dave','Laura','Laura','Ben','Ben','Bobby','Bobby','Anna'),ncol=2)

edge_dir = graph.edgelist(edge_l)
edge_und = graph.edgelist(edge_l, directed = F)

set.seed(123)
plot(edge_und, layout = layout_as_star)

edge_und = set_edge_attr(edge_und,"weight",value = c(5,1,2,3,2)) # Putting in some edge weights. Let's suppose that the weights represent how much one person knows another person...
plot(edge_und,edge.width=E(edge_und)$weight*1.5, layout = layout_as_star) # we can now represent how well people know each other by using the thickness of the edges
