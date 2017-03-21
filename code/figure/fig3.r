library(ggplot2)
library(scales)
df = read.table('client_qrcnt_fig_3.id.rev') 
#df = read.table('test.rev') 

# theme(text = element_text(size=20), axis.text.x = element_text(angle=90, vjust=1)) 

sp10 <- ggplot(df, aes(V1, V2)) + geom_line() +
theme(text = element_text(size=13)) +
scale_y_log10(
              name = 'Queried Times',
              breaks = trans_breaks("log10", function(x) 10^x),
                 labels = trans_format("log10", math_format(10^.x))) +
scale_x_log10(
              name = 'Client ID', 
              breaks = trans_breaks("log10", function(x) 10^x),
                 labels = trans_format("log10", math_format(10^.x)))

print(sp10)

ggsave('fig3.png')
