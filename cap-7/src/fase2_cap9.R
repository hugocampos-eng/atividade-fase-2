pacotes <- c("dplyr", "ggplot2", "moments")
for(p in pacotes){
  if(!require(p, character.only = TRUE)){
    install.packages(p, repos = "https://cloud.r-project.org")
    library(p, character.only = TRUE)
  }
}


caminho_csv <- "../data/data_agro.csv"
dados <- read.csv(caminho_csv, stringsAsFactors = FALSE, encoding = "UTF-8")


head(dados)
str(dados)
summary(dados)


names(dados) <- make.names(names(dados))


dados$Produtividade_sacas_ha <- as.numeric(dados$Produtividade_sacas_ha)
dados.Num.Func <- "Número_de_Funcionários"  
if (dados.Num.Func %in% names(dados)) {
  dados[[dados.Num.Func]] <- as.integer(dados[[dados.Num.Func]])
}


sum(is.na(dados))                 
colSums(is.na(dados))             


if(sum(is.na(dados$Produtividade_sacas_ha)) > 0){
  warning("Existem NA em Produtividade_sacas_ha. Considere imputar ou remover antes da análise.")
}


ordem_safra <- c("Baixa", "Média", "Alta")
if("Classificação_da_Safra" %in% names(dados)){
  dados$Classificacao_da_Safra <- factor(dados$Classificação_da_Safra,
                                         levels = ordem_safra,
                                         ordered = TRUE)
} else if("Classificacao.da.Safra" %in% names(dados)){
  dados$Classificacao_da_Safra <- factor(dados$Classificacao.da.Safra,
                                         levels = ordem_safra,
                                         ordered = TRUE)
}



x <- dados$Produtividade_sacas_ha


media <- mean(x, na.rm = TRUE)           
mediana <- median(x, na.rm = TRUE)       

get_mode <- function(v){
  v <- v[!is.na(v)]
  uniqv <- unique(v)
  tab <- tabulate(match(v, uniqv))
  uniqv[tab == max(tab)]
}
moda <- get_mode(x)


variancia <- var(x, na.rm = TRUE)
desvio_padrao <- sd(x, na.rm = TRUE)
coef_var <- (desvio_padrao / media) * 100  # coeficiente de variação em %


quartis <- quantile(x, probs = c(0.25, 0.5, 0.75), na.rm = TRUE)
iqr_val <- IQR(x, na.rm = TRUE)            # intervalo interquartil
percentis <- quantile(x, probs = c(0.1, 0.25, 0.5, 0.75, 0.9), na.rm = TRUE)


assimetria <- moments::skewness(x, na.rm = TRUE)
curtose <- moments::kurtosis(x, na.rm = TRUE)


estatisticas <- data.frame(
  Estatistica = c("N", "Média", "Mediana", "Moda", "Variância", "Desvio.Padrão", "Coef.Variacao(%)", 
                  "Q1", "Q2(Mediana)", "Q3", "IQR", "Assimetria", "Curtose"),
  Valor = c(length(na.omit(x)), round(media,2), round(mediana,2), paste(round(moda,2), collapse = ", "),
           round(variancia,2), round(desvio_padrao,2), round(coef_var,2),
           round(quartis[1],2), round(quartis[2],2), round(quartis[3],2), round(iqr_val,2),
           round(assimetria,3), round(curtose,3))
)
print(estatisticas)


write.csv(estatisticas, file = "../output/estatisticas_produtividade.csv", row.names = FALSE)


png("../output/histograma_produtividade.png", width = 800, height = 600)
hist(x, breaks = 10, main = "Histograma da Produtividade (sacas/ha)",
     xlab = "Produtividade (sacas/ha)", probability = TRUE)
lines(density(x, na.rm = TRUE))   # curva de densidade sobre o histograma
dev.off()


png("../output/boxplot_produtividade.png", width = 600, height = 400)
boxplot(x, main = "Boxplot da Produtividade", ylab = "Produtividade (sacas/ha)")
dev.off()


png("../output/qqplot_produtividade.png", width = 600, height = 400)
qqnorm(x, main = "QQ-Plot da Produtividade")
qqline(x, col = "red")
dev.off()


p <- ggplot(dados, aes(x = Produtividade_sacas_ha)) +
  geom_histogram(aes(y = ..density..), bins = 12) +
  geom_density(alpha = 0.2) +
  labs(title = "Histograma + Densidade: Produtividade", x = "Produtividade (sacas/ha)", y = "Densidade")
ggsave("ggplot_hist_densidade_produtividade.png", plot = p, width = 8, height = 5, dpi = 150)


if(!"Classificacao_da_Safra" %in% names(dados)){
  stop("Coluna 'Classificacao_da_Safra' não encontrada. Verifique nomes de colunas.")
}


freq_abs <- table(dados$Classificacao_da_Safra)
freq_rel <- prop.table(freq_abs) * 100  # porcentagem


freq_tabela <- data.frame(
  Classificacao = names(freq_abs),
  Frequencia = as.vector(freq_abs),
  Porcentagem = round(as.vector(freq_rel), 2)
)
print(freq_tabela)


write.csv(freq_tabela, file = "../output/frequencia_classificacao_safra.csv", row.names = FALSE)


png("../output/barplot_classificacao_safra.png", width = 700, height = 500)
barplot(freq_abs, main = "Frequência da Classificação da Safra",
        ylab = "Contagem", xlab = "Classificação", ylim = c(0, max(freq_abs) + 5))
text(x = seq_along(freq_abs), y = freq_abs, labels = freq_abs, pos = 3)
dev.off()


p2 <- ggplot(dados, aes(x = Classificacao_da_Safra)) +
  geom_bar() +
  labs(title = "Contagem por Classificação da Safra", x = "Classificação", y = "Contagem")
ggsave("../output/ggplot_bar_classificacao_safra.png", plot = p2, width = 7, height = 5, dpi = 150)


cat("\n--- INTERPRETAÇÕES EXEMPLO ---\n")
cat(sprintf("Média de produtividade: %.2f s/ha\n", media))
cat(sprintf("Mediana: %.2f s/ha — indica o valor central (50%%)\n", mediana))
cat(sprintf("Coeficiente de variação: %.2f%% — indica variação relativa.\n", coef_var))
if(assimetria > 0) {
  cat(sprintf("Assimetria positiva (%.3f): cauda à direita (valores altos mais extremos)\n", assimetria))
} else if (assimetria < 0) {
  cat(sprintf("Assimetria negativa (%.3f): cauda à esquerda (valores baixos mais extremos)\n", assimetria))
} else {
  cat("Assimetria ~ 0: distribuição simétrica.\n")
}
cat(sprintf("Curtose: %.3f — valores >3 indicam cauda pesada, <3 cauda leve (comparação depende da definição adotada).\n", curtose))

cat("\nFrequências da classificação da safra:\n")
print(freq_tabela)


