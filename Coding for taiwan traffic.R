#資料前處理(事件編號)
library(dplyr)
library(data.table)
A1<-read.csv("A1.csv")
A1<-A1[-(3909:3910),] #刪除資料備注
A1<-A1[,-(29:49)] #刪除不用的欄位
A1<-A1[,-c(1,2,5,6,11,12,14,20,23,25)]
A1 <- A1 %>% 
  mutate(事件編號 = NA)
A1<-A1[,c(1:3,21,19:20,4:18)]
setDT(A1)[, 事件編號 := rleid(發生地點)] #給資料編號並移除重複值
A1 <- A1 %>%
  distinct(事件編號, .keep_all = TRUE)

#處理欄位名稱跟資料型態
for (i in 7:21) {
  col_name <- paste0("x", i - 6)  # 新的列名，例如，第10列变成"x1"
  colnames(A1)[i] <- col_name
}
A1[, 7:21] <- lapply(A1[, 7:21], as.factor)
summary(A1)

#獲取GIS座標
library(sf)
A1_sf <- st_as_sf(A1[, 4:6], 
                  coords = c("經度", "緯度"), 
                  crs = 4326)
colnames(A1_sf)[1] <- "ID"
st_write(A1_sf, "C:/Users/s0958/Downloads/A1_shp.shp")#記得改路徑

#空間分析
library(spdep)
library(tmap)
#台灣地圖縣市資料
taiwan_city <- st_read("mapdata/country.shp") 
A1_sf <- st_set_crs(A1_sf, st_crs(taiwan_city))
merged_city <- st_join(A1_sf, taiwan_city, join = st_within)
taiwan_town <- st_read("map/town.shp") #記得改路徑
merged_town <- st_join(A1_sf, taiwan_town, join = st_within)
#A1車禍分布_群聚分析
library(ggplot2)
library(sf)

ggplot() +
  geom_sf(data = taiwan_city, fill = NA) +
  geom_sf(data = merged_city, color = "red", size = 0.3) +
  coord_sf(xlim = c(119.5, 122.5), ylim = c(21, 26))
ggplot() +
  geom_sf(data = taiwan_town, fill = NA) +
  geom_sf(data = merged_town, color = "red", size = 0.3) +
  coord_sf(xlim = c(119.5, 122.5), ylim = c(21, 26))
#點模式分析
library(spatstat)
coords <- st_coordinates(merged_town)
unique_coords <- unique(coords)
accidents_ppp <- ppp(unique_coords[, "X"], unique_coords[, "Y"], 
                     window = owin(c(min(unique_coords[, "X"]), max(unique_coords[, "X"])), 
                                   c(min(unique_coords[, "Y"]), max(unique_coords[, "Y"]))))
plot(Kest(accidents_ppp), main = "Ripley's K Function")
plot(Lest(accidents_ppp))
L<-Lest(accidents_ppp)
L1<-L$iso-L$r
plot(L1,type="l")
plot(envelope(accidents_ppp,fun=Kest,nsim=99,nrank=1))
plot(envelope(accidents_ppp,fun=Lest,nsim=99,nrank=1))
plot(envelope(accidents_ppp,fun=Gest,nsim=99,nrank=1))
plot(envelope(accidents_ppp,fun=Fest,nsim=99,nrank=1))

#樣方分析
grid <-st_sf(st_make_grid(A1_sf, n=c(100,100)))
num<-lengths(st_contains(grid, A1_sf))
#VMR檢定──t統計量單尾檢定
S.vmr<-var(num)/mean(num)
S.se<-sqrt(2/(nrow(grid)-1))
S.t<-(S.vmr-1)/S.se
sprintf("VMR統計量為%.4f，t值為%.4f。當顯著水準為0.05，右尾檢定的臨界值為%.3f，因此落入拒絕域，表空間上有顯著群聚特徵。",S.vmr,S.t,qt(0.95,(nrow(grid)-1)))

#最鄰近分析
library(shotGroups)
MBR<-getMinBBox(st_coordinates(A1_sf))
A1_sf.area<-MBR$width*MBR$height
# nndist函數：計算k階鄰近點之距離，預設k=1
r_obs<-mean(nndist(accidents_ppp))
r_exp<-sqrt(A1_sf.area/nrow(A1_sf))/2
se<-0.26136*sqrt(A1_sf.area)/nrow(A1_sf)
R<-r_obs/r_exp
z<-(r_obs-r_exp)/se
sprintf("R值為%.4f，z值為%.4f。",R,z)

library(ggplot2) #核密度
library(MASS)
data_df <- data.frame(x = coords[, "X"], y = coords[, "Y"])
density <- kde2d(data_df$x, data_df$y)
ggplot() +
  geom_sf(data = taiwan_town, fill = "white", color = "black") +
  geom_point(data = data_df, aes(x = x, y = y), alpha = 0.1, color = "blue") +
  geom_density_2d(data = data_df, aes(x = x, y = y), color = "red") +
  labs(x = "經度", y = "緯度") +
  coord_sf(xlim = c(min(data_df$x), max(data_df$x)), ylim = c(22, 26)) +  # 调整 x 和 y 范围
  theme_minimal()

#DBSCAN
library(dbscan)
dbscan=dbscan(st_coordinates(A1_sf),eps=0.04,minPts=5)
par(mar=c(5,4,3,3))
hullplot(st_coordinates(A1_sf), dbscan, asp = 1, main = "DBSCAN for A1 accident", axes = FALSE)
plot(st_geometry(taiwan_town),add=T)


#相關性-heatmap
library(tidyr)
library(Hmisc)
your_data <- data.frame(A1[, 7:21])

cramers_v <- function(x, y) {
  confusion_matrix <- table(x, y)
  chi2 <- chisq.test(confusion_matrix)$statistic
  n <- sum(confusion_matrix)
  min_dim <- min(nrow(confusion_matrix), ncol(confusion_matrix))
  cramers_v <- sqrt(chi2 / (n * (min_dim - 1)))
  return(cramers_v)
}

num_vars <- ncol(your_data)
cramer_matrix <- matrix(NA, nrow = num_vars, ncol = num_vars)
colnames(cramer_matrix) <- rownames(cramer_matrix) <- paste0("V", 1:num_vars)

for (i in 1:num_vars) {
  for (j in 1:num_vars) {
    if (i != j) {  # 避免計算對角線上的值
      # 使用 suppressWarnings 屏蔽警告
      suppressWarnings({
        cramer_matrix[i, j] <- cramers_v(your_data[[i]], your_data[[j]])
      })
    }
  }
}
cramer_matrix <- as.matrix(cramer_matrix)
cramer_matrix[is.na(cramer_matrix)] <- 1

library(gplots)
heat_result<-heatmap.2(cramer_matrix,
                       Rowv = TRUE,   
                       Colv = TRUE,     
                       col = colorRampPalette(c("white", "blue"))(100),
                       scale = "none",
                       main = "Cramér's V Heatmap",
                       key = TRUE,          
                       key.title = NA,     
                       cexRow = 0.8,       
                       cexCol = 0.8,       
                       keysize = 1.5)

par(mar = c(5, 4, 2, 2))
plot(heat_result$rowDendrogram, main = "Row Dendrogram")
cut_value <- 1.5 
abline(h = cut_value, col = "red")
data1<-your_data[,c(7,9,11)]

#mca
library(factoextra)
library(FactoMineR)
mca_obj <- MCA(data1,graph = FALSE)
mca_obj$eig
var_loadings <- fviz_mca_var(mca_obj, col.var = "contrib", 
                             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                             repel = TRUE)
print(var_loadings)
fviz_screeplot(mca_obj, addlabels = TRUE)
cum_prop <- mca_obj$eig[,3]
par(mfrow = c(1, 1), mar = c(4, 4, 2, 1), cex = 0.8)
plot(cum_prop, xlab = "Number of Dimensions", ylab = "Cumulative Proportion", main = "Cumulative Probability Plot",pch=20)

