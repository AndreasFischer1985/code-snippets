#!/usr/bin/Rscript

cc=geodata::country_codes()
dat=geodata::elevation_30s("DEU",getwd())
g=ggplot2::ggplot() +
    tidyterra::geom_spatraster(data = dat)+
    tidyterra::scale_fill_hypso_tint_c(
      limits = c(0,3000),
      palette = "wiki-2.0_hypso" 
    ) +
    ggplot2::labs(fill="Elevation")+
    ggplot2::ggtitle("Map of Germany") +
    ggplot2::theme_minimal()
ggplot2::ggsave("ElevationMapOfGermany.png")
