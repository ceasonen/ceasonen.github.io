sed -i '' 's/\\keyalignment{r}/\\makeatletter\n\\renewcolumntype{k}{>{\\\@keyfont\\raggedleft\\arraybackslash}p{3.5cm}}\n\\makeatother\n\\keyalignment{r}/g' settings.sty
