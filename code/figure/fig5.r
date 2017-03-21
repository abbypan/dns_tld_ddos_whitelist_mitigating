library(ggplot2)
library(scales)
df = read.table('fig5.csv') 

sp10 <- ggplot(df, aes(V1, V2)) + geom_line() +
theme(text = element_text(size=11.2)) +
scale_y_log10(
              name = 'Cover Caching Recursive DNS Number',
              breaks = trans_breaks("log10", function(x) 10^x),
                 labels = trans_format("log10", math_format(10^.x))) +
scale_x_log10(
              name = 'Forwarding Recursive DNS ID', 
              breaks = trans_breaks("log10", function(x) 10^x),
                 labels = trans_format("log10", math_format(10^.x)))

print(sp10)

ggsave('fig5.png')
