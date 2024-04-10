# ******************************************************************************
# ******************************************************************************
# *Authors: 
# *Coder: Edmundo Arias De Abreu
# *Project: HE2 Project
# *Data: Panel.xlsx
# *Stage: Descriptive Stats & Graphs
# 
# *Last checked: 04.04.2024
# 
# /*
# ******************************************************************************
# *                                 Contents                                   *
# ******************************************************************************
#   
# This script aims to...
#
#
#     Inputs:
#       - Panel.xlsx
# 
#     Output:
#       - figures & tables
# 
# ******************************************************************************
# Clear the Environment
# ---------------------------------------------------------------------------- #

rm(list = ls())

# ---------------------------------------------------------------------------- #
# Load Necessary Libraries
# ---------------------------------------------------------------------------- #
library(tidyverse)  # Essentials
library(readxl)     # For reading Excel files
library(openxlsx)   # For exporting Excel files
library(kableExtra)
library(knitr)      # For summary stats 

# ---------------------------------------------------------------------------- #
# Data Import 
# ---------------------------------------------------------------------------- #

# Import Panel
data <- read_excel("/Users/edmundoarias/Documents/Uniandes/2024-10/HE 2/Exchange-Rate-Intervention/2:_ProcessedData/Panel.xlsx", col_types = c("date", "numeric", "text", "numeric", "numeric", "numeric"))

# ---------------------------------------------------------------------------- #
# Summary Statistics 
# ---------------------------------------------------------------------------- #

# Calculate summary statistics for the exchange rate overall
exchange_rate_stats <- data %>% 
  summarise(Count = n(),
            Mean = mean(Exchange.Rate, na.rm = TRUE),
            SD = sd(Exchange.Rate, na.rm = TRUE),
            Min = min(Exchange.Rate, na.rm = TRUE),
            `25th Percentile` = quantile(Exchange.Rate, 0.25, na.rm = TRUE),
            Median = median(Exchange.Rate, na.rm = TRUE),
            `75th Percentile` = quantile(Exchange.Rate, 0.75, na.rm = TRUE),
            Max = max(Exchange.Rate, na.rm = TRUE))

# Calculate summary statistics for days with intervention
exchange_rate_with_intervention <- data %>%
  filter(Intervention == 1) %>%
  summarise(Count = n(),
            Mean = mean(Exchange.Rate, na.rm = TRUE),
            SD = sd(Exchange.Rate, na.rm = TRUE),
            Min = min(Exchange.Rate, na.rm = TRUE),
            `25th Percentile` = quantile(Exchange.Rate, 0.25, na.rm = TRUE),
            Median = median(Exchange.Rate, na.rm = TRUE),
            `75th Percentile` = quantile(Exchange.Rate, 0.75, na.rm = TRUE),
            Max = max(Exchange.Rate, na.rm = TRUE))


# Calculate summary statistics for days without intervention
exchange_rate_without_intervention <- data %>%
  filter(Intervention != 1) %>%
  summarise(Count = n(),
            Mean = mean(Exchange.Rate, na.rm = TRUE),
            SD = sd(Exchange.Rate, na.rm = TRUE),
            Min = min(Exchange.Rate, na.rm = TRUE),
            `25th Percentile` = quantile(Exchange.Rate, 0.25, na.rm = TRUE),
            Median = median(Exchange.Rate, na.rm = TRUE),
            `75th Percentile` = quantile(Exchange.Rate, 0.75, na.rm = TRUE),
            Max = max(Exchange.Rate, na.rm = TRUE))


# Bind rows for a comparative table (optional, depending on desired format)
comparative_stats <- rbind(exchange_rate_stats %>% mutate(Condition = "Overall"),
                           exchange_rate_with_intervention %>% mutate(Condition = "With Intervention"),
                           exchange_rate_without_intervention %>% mutate(Condition = "Without Intervention"))

# Table format (further adjust)
kable(comparative_stats, format = "html", 
      caption = "Comparative Summary Statistics for Exchange Rate") %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"))


# ---------------------------------------------------------------------------- #
# Graphs
# ---------------------------------------------------------------------------- #
library(scales)  # For date format

data$Date <- as.Date(data$Date)

# Exchange Rate Time Series
ggplot(data, aes(x = Date, y = Exchange.Rate)) +
  geom_line() +  # Creates the line plot
  labs(title = "Time Series of Exchange Rate",
       x = "Date",
       y = "Exchange Rate (COP/USD") +
  theme_minimal() +
  theme(text = element_text(family = "Times New Roman"),  # Change font to Times New Roman
        panel.grid.major = element_blank(),  # Remove major gridlines
        panel.grid.minor = element_blank(),  # Remove minor gridlines
        axis.text.x = element_text(angle = 45, hjust = 1)) +  # Improve x-axis label readability
  scale_x_date(date_breaks = "5 years", date_labels = "%Y")  # X-axis in 5-year intervals



# Distribution of Exchange Rate
ggplot(data, aes(x = Exchange.Rate, fill = as.factor(Intervention))) +
  geom_density(alpha = 0.5) +
  labs(title = "Distribution of Exchange Rates by Intervention", x = "Exchange Rate", y = "Density") +
  scale_fill_discrete(name = "Intervention") +
  theme_minimal()



# Scatter
data <- data %>%
  mutate(Total_Int = Sales + Purchases)

data <- data %>%
  mutate(exchange_change = c(NA, diff(Exchange.Rate)))

ggplot(data, aes(x = Total_Int, y = exchange_change)) +
  geom_point() +
  geom_smooth(method = "lm", color = "blue") +
  labs(title = "Intervention Magnitude and Exchange Rate Change", x = "Total Intervention (Sales + Purchases)", y = "Daily Change in Exchange Rate") +
  theme_minimal()



# Bubble Plot

# Step 1: Prepare the data by calculating Exchange.Rate.Change
data <- data %>%
  group_by(Type) %>%
  arrange(Type, Date) %>%
  mutate(Exchange.Rate.Change = Exchange.Rate - lag(Exchange.Rate, default = first(Exchange.Rate))) %>%
  ungroup() # Ungroup to apply further operations on the entire dataset

# Step 2: Ensure Type is a factor and exclude NA
data$Type <- factor(data$Type)
data <- filter(data, !is.na(Type))

# Step 3: Identify and keep only the top 4 Types based on their count
top_types <- data %>%
  count(Type, sort = TRUE) %>%
  slice_max(n, n = 4) %>%
  pull(Type)

# Step 4: Filter data to keep only rows with the top 4 Types
filtered_data <- data %>%
  filter(Type %in% top_types)

# Now, verify if the top_types vector contains exactly 4 types
print(top_types)

# Create the bubble plot with the filtered dataset, now adding color to distinguish intervention types
ggplot(filtered_data, aes(x = Type, y = Exchange.Rate.Change, size = Total_Int, color = Type)) +
  geom_jitter(alpha=0.5, width = ) +
  scale_size_continuous(name = "Magnitude of Intervention (Millions USD)" ) +
  scale_color_manual(values = c("#4E79A7", "#F28E2B", "#E15759", "#76B7B2", "#59A14F", "#EDC948", "#B07AA1", "#FF9DA7"),
                     guide = FALSE) + # Darker colors, no legend for Type
  geom_hline(yintercept = 0, linetype = "dotted", color = "black") + # Dotted horizontal line at y = 0
  labs(
    title = "Exchange Rate Change vs. Intervention Type",
    x = "Intervention Type",
    y = "Exchange Rate Change"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom", # Legend at the bottom
        legend.justification = "right", # Align legend to the right
        panel.grid.major = element_blank(), # No major gridlines
        panel.grid.minor = element_blank(), # No minor gridlines
        axis.title.x = element_text(margin = margin(t = 20))) # Move x-axis title lower by adjusting the top margin



# Paper: graph 1 Bar chart

# Ensure the Date is in Date format
data$Date <- as.Date(data$Date)

# Extract the year from the Date
data$Year <- format(data$Date, "%Y")

# Reshape the data from wide to long format
long_data <- data %>%
  select(Date, Year, Sales, Purchases) %>%
  pivot_longer(cols = c(Sales, Purchases), names_to = "Intervention_Type", values_to = "Total_Int")

# Aggregate data by Year and Intervention Type
annual_data <- long_data %>%
  group_by(Year, Intervention_Type) %>%
  summarize(Total_Annual_Int = sum(Total_Int, na.rm = TRUE)) %>%
  ungroup()


# Filter data for years 2001 to 2023
annual_data <- annual_data %>%
  filter(Year >= "2001" & Year <= "2023")


### Definitive !
ggplot(annual_data, aes(x = Year, y = Total_Annual_Int, fill = Intervention_Type)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("Sales" = "#4E79A7", "Purchases" = "#F28E2B")) + # More formal colors
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  labs(
    title = "Colombian Central Bank Interventions",
    x = "Year",
    y = "US $Millions",
    fill = "Intervention"
  ) +
  scale_x_discrete(breaks = function(x) seq(min(x), max(x), by = 1)) # Adjust for less clutter



## Extra graph options (leave them here if needed later)

# # Filter data for years 2000 to 2012
# annual_data_2000_2012 <- annual_data %>%
#   filter(Year >= "2000" & Year <= "2012")
# 
# # Plot
# ggplot(annual_data_2000_2012, aes(x = Year, y = Total_Annual_Int, fill = Intervention_Type)) +
#   geom_bar(stat = "identity", position = "dodge") +
#   theme_minimal() +
#   labs(title = "Annual Central Bank Intervention by Type (2000-2012)",
#        x = "Year",
#        y = "Total Amount of Intervention",
#        fill = "Intervention Type") +
#   scale_fill_brewer(palette = "Set1")
# 
# 
# # Filter data for years 2013 to 2024
# annual_data_2013_2024 <- annual_data %>%
#   filter(Year >= "2013" & Year <= "2024")
# 
# # Plot
# ggplot(annual_data_2013_2024, aes(x = Year, y = Total_Annual_Int, fill = Intervention_Type)) +
#   geom_bar(stat = "identity", position = "dodge") +
#   theme_minimal() +
#   labs(title = "Annual Central Bank Intervention by Type (2013-2024)",
#        x = "Year",
#        y = "Total Amount of Intervention",
#        fill = "Intervention Type") +
#   scale_fill_brewer(palette = "Set1")


