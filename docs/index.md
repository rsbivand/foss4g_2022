---
title: "Modernizing the R-GRASS interface: confronting barn-raised OSGeo libraries and the evolving R.*spatial package ecosystem"
author: "Roger Bivand"
date: "22 August 2022"
output: 
  html_document:
theme: united
---

### [Workshop document](https://rsbivand.github.io/foss4g_2022/modernizing_220822.html)


Installing packages not yet on your system:

```
inst <- match(needed, .packages(all=TRUE))
need <- which(is.na(inst))
if (length(need) > 0) install.packages(needed[need])
```
