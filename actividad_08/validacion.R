library(tidyverse)
library(janitor)

data = read.csv("trafico experimento-flujo-table.csv", skip=6) |> 
  janitor::clean_names()

p = data |> 
  filter(x_step == max(data$x_step)) |> 
  ggplot(aes(x=numero_de_carros, y=mean_lista_flujo)) +
  geom_point(position = "jitter") + 
  labs(x = "Densidad" , y = "Flujo", title = "Densidad vs Flujo") +
  scale_x_continuous(breaks = seq(0, 30, by = 5))+
  geom_tile()


ggsave("validacion.png", plot = p, width = 8, height = 5)

