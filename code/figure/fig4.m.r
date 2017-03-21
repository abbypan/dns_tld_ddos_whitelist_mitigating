library(ggplot2)
library(scales)
df = read.table('client_qrcnt_fig_4.id.stat') 
#df = read.table('test.rev') 

sp10 <- ggplot(df, aes(V1, V4)) + geom_line() +
theme(text = element_text(size=13)) +
scale_y_continuous(
                   name = 'Query Times Cumulative Percent',
                   labels = percent
                   ) +
# + geom_hline(yintercept=20, linetype="dashed", color = "red")
scale_x_log10(
              name = 'Client ID', 
              breaks = trans_breaks("log10", function(x) 10^x),
                 labels = trans_format("log10", math_format(10^.x)))

print(sp10)

ggsave('fig4.png')

