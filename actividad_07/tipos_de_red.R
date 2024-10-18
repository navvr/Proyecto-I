library(tidyverse)
library(janitor)

data = read_csv("experiment_tipo_red-table.csv", 
                skip = 6 ) |>
      janitor::clean_names()

data |> 
  filter(step == max(data$step)) |> 
  ggplot(aes(x = gamma, y = psi)) + 
  geom_point(alpha = .5) + 
  facet_grid(. ~ tipo_red + "h=8") + 
  labs(x = expression(gamma), y = expression(Psi) ) + 
  scale_x_continuous(breaks = seq(0,1,by=.2))
