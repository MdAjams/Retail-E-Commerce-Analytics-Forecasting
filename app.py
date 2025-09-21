# main.py
import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
from io import BytesIO
from streamlit.components.v1 import html as components_html

# Optional animations
try:
    from streamlit_lottie import st_lottie
    import requests

    def load_lottie(url):
        try:
            r = requests.get(url, timeout=6)
            if r.status_code == 200:
                return r.json()
        except:
            return None
except:
    st_lottie = None
    def load_lottie(url): return None

# ---------------- Config ----------------
st.set_page_config(
    page_title="Retail Intelligence • Md Ajam",
    page_icon="🛒",
    layout="wide",
)

# ---------------- Helpers ----------------
@st.cache_data
def load_data():
    sales = pd.read_excel("sales_summary.xlsx", engine="openpyxl")
    churned = pd.read_excel("churn_analysis.xlsx", sheet_name="Churned_Customers", engine="openpyxl")
    churn_summary = pd.read_excel("churn_analysis.xlsx", sheet_name="Churn_Summary", engine="openpyxl")
    forecast = pd.read_excel("forecast_summary.xlsx", engine="openpyxl")

    for df in [sales, churned, churn_summary, forecast]:
        df.columns = df.columns.str.strip().str.lower()

    if "order_date" in sales.columns:
        sales["order_date"] = pd.to_datetime(sales["order_date"], errors="coerce")
    if "date" in forecast.columns:
        forecast["date"] = pd.to_datetime(forecast["date"], errors="coerce")
    return sales, churned, churn_summary, forecast

def to_excel_bytes(df):
    out = BytesIO()
    with pd.ExcelWriter(out, engine="openpyxl") as writer:
        df.to_excel(writer, index=False)
    return out.getvalue()

# ---------------- Load Data ----------------
sales_df, churned_df, churn_summary_df, forecast_df = load_data()

# ---------------- Sidebar Filters ----------------
st.sidebar.header("Filters & What-if")
countries = sorted(sales_df["country_name"].dropna().unique().tolist())
categories = sorted(sales_df["category"].dropna().unique().tolist())
products = sorted(sales_df["product_name"].dropna().unique().tolist())

selected_countries = st.sidebar.multiselect("🌍 Country", countries, default=countries)
selected_categories = st.sidebar.multiselect("📦 Category", categories, default=categories)
selected_products = st.sidebar.multiselect("🏷️ Product", products, default=[])

if "order_date" in sales_df.columns:
    min_d, max_d = sales_df["order_date"].min(), sales_df["order_date"].max()
    date_range = st.sidebar.date_input("📅 Date range", [min_d, max_d])
else:
    date_range = None

growth_pct = st.sidebar.slider("Growth (%)", -20, 50, 5)
churn_red = st.sidebar.slider("Churn Reduction (%)", 0, 50, 10)
discount_pct = st.sidebar.slider("Discount (%)", -10, 10, 0)

# ---------------- Apply filters ----------------
fsales = sales_df.copy()
if selected_countries: fsales = fsales[fsales["country_name"].isin(selected_countries)]
if selected_categories: fsales = fsales[fsales["category"].isin(selected_categories)]
if selected_products: fsales = fsales[fsales["product_name"].isin(selected_products)]
if date_range and len(date_range)==2:
    fsales = fsales[(fsales["order_date"]>=pd.to_datetime(date_range[0])) & (fsales["order_date"]<=pd.to_datetime(date_range[1]))]

fchurn_summary = churn_summary_df.copy()
if "country_name" in fchurn_summary.columns and selected_countries:
    fchurn_summary = fchurn_summary[fchurn_summary["country_name"].isin(selected_countries)]

fforecast = forecast_df.copy()
if "country_name" in fforecast.columns and selected_countries:
    fforecast = fforecast[fforecast["country_name"].isin(selected_countries)]

# ---------------- Hero ----------------
col1,col2=st.columns([3,1])
with col1:
    st.markdown("<h1 style='color:#0b3d91;'>Retail Intelligence & Forecasting Platform</h1>", unsafe_allow_html=True)
    st.markdown("**By Md Ajam** | Sales • Customers • Forecast • Insights")
with col2:
    if st_lottie:
        lottie = load_lottie("https://assets2.lottiefiles.com/packages/lf20_jcikwtux.json")
        if lottie: st_lottie(lottie, height=120)

st.markdown("---")

# ---------------- KPI Cards ----------------
def animated_kpi_html(title, value, gradient, icon=""):
    uid = np.random.randint(1e9)  # unique ID
    return f"""
    <div style="background: {gradient};
                border-radius:14px;
                padding:18px;
                color:white;
                box-shadow:0 6px 20px rgba(0,0,0,0.15);
                text-align:center;
                height:140px; 
                display:flex;
                flex-direction:column;
                justify-content:center;">
      <div style="font-size:20px;font-weight:700;line-height:1.2;">{icon} {title}</div>
      <div id="val{uid}" style="font-size:28px;font-weight:800;line-height:1.4;">0</div>
    </div>
    <script>
      let el = document.getElementById("val{uid}");
      let target = {int(value)};
      let cur = 0;
      let step = Math.ceil(target/60);
      function run() {{
        cur += step;
        if(cur >= target) {{
          el.innerText = target.toLocaleString();
        }} else {{
          el.innerText = cur.toLocaleString();
          requestAnimationFrame(run);
        }}
      }}
      run();
    </script>
    """

# ---- KPI Values ----
total_revenue = fsales["total_revenue"].sum() if "total_revenue" in fsales else 0
total_customers = fsales["customer_id"].nunique() if "customer_id" in fsales else 0
total_orders = fsales["order_id"].nunique() if "order_id" in fsales else 0
aov = total_revenue / total_orders if total_orders else 0

# ---- KPI Layout ----
c1, c2, c3, c4 = st.columns(4)
with c1:
    components_html(animated_kpi_html("Revenue", total_revenue, "linear-gradient(135deg,#667eea,#764ba2)", "💰"), height=160)
with c2:
    components_html(animated_kpi_html("Customers", total_customers, "linear-gradient(135deg,#ff758c,#ff7eb3)", "👥"), height=160)
with c3:
    components_html(animated_kpi_html("Orders", total_orders, "linear-gradient(135deg,#43cea2,#185a9d)", "🛍️"), height=160)
with c4:
    components_html(animated_kpi_html("AOV", int(aov), "linear-gradient(135deg,#ff9966,#ff5e62)", "📦"), height=160)

st.markdown("---")

# ---------------- Tabs ----------------
tab1,tab2,tab3,tab4,tab5=st.tabs(["📈 Sales","👥 Segmentation","❌ Churn","🔮 Forecast","🧰 Tools"])

# Sales
with tab1:
    st.subheader("Sales Overview")
    if "order_date" in fsales:
        monthly=fsales.groupby(fsales["order_date"].dt.to_period("M"))["total_revenue"].sum().reset_index()
        monthly["month"]=monthly["order_date"].astype(str)
        fig=px.line(monthly,x="month",y="total_revenue",title="Monthly Revenue",markers=True)
        st.plotly_chart(fig,use_container_width=True)
    if "country_name" in fsales:
        region=fsales.groupby("country_name")["total_revenue"].sum().reset_index()
        fig=px.bar(region,x="country_name",y="total_revenue",title="Revenue by Country",color="total_revenue")
        st.plotly_chart(fig,use_container_width=True)

# Segmentation
with tab2:
    st.subheader("Customer Segmentation (RFM)")
    df_rfm=sales_df.groupby("customer_id").agg(
        recency=("order_date", lambda x:(sales_df["order_date"].max()-x.max()).days),
        frequency=("order_id","nunique"),
        monetary=("total_revenue","sum")
    ).reset_index()
    df_rfm["recency"]=df_rfm["recency"].fillna(999)
    df_rfm["frequency"]=df_rfm["frequency"].fillna(0)
    df_rfm["monetary"]=df_rfm["monetary"].fillna(0)
    df_rfm["r_score"]=pd.qcut(df_rfm["recency"],5,labels=[5,4,3,2,1])
    df_rfm["f_score"]=pd.qcut(df_rfm["frequency"].rank(method="first"),5,labels=[1,2,3,4,5])
    df_rfm["m_score"]=pd.qcut(df_rfm["monetary"].rank(method="first"),5,labels=[1,2,3,4,5])
    df_rfm["rfm_sum"]=df_rfm[["r_score","f_score","m_score"]].astype(int).sum(1)
    df_rfm["segment"]=df_rfm["rfm_sum"].apply(lambda s:"Champions" if s>=13 else "Loyal" if s>=10 else "Potential" if s>=7 else "At Risk")
    seg_counts=df_rfm["segment"].value_counts().reset_index()
    seg_counts.columns=["segment","count"]
    fig=px.bar(seg_counts,x="segment",y="count",color="segment",title="Segment Distribution",text_auto=True)
    st.plotly_chart(fig,use_container_width=True)

# Churn
with tab3:
    st.subheader("Churn Analysis")
    if not fchurn_summary.empty:
        fig=px.bar(fchurn_summary,x="country_name",y="total_churned",title="Churned by Country",color="total_churned")
        st.plotly_chart(fig,use_container_width=True)
    if not churned_df.empty:
        st.dataframe(churned_df.head(10))

# Forecast
with tab4:
    st.subheader("Forecast & What-if")
    if not fforecast.empty:
        fig=px.line(fforecast,x="date",y="forecast_revenue",title="Forecasted Revenue",markers=True)
        st.plotly_chart(fig,use_container_width=True)
        if {"lower_ci","upper_ci"}.issubset(fforecast.columns):
            fig_ci=px.line(fforecast,x="date",y=["lower_ci","forecast_revenue","upper_ci"],title="Forecast w/ CI")
            st.plotly_chart(fig_ci,use_container_width=True)
        sim=fforecast.copy()
        sim["sim_revenue"]=sim["forecast_revenue"]*(1+growth_pct/100)*(1-discount_pct/100)*(1+churn_red/100)
        fig_sim=px.line(sim,x="date",y=["forecast_revenue","sim_revenue"],title="Simulated Forecast")
        st.plotly_chart(fig_sim,use_container_width=True)

# Tools
with tab5:
    st.subheader("Export Tools")
    if not fsales.empty:
        st.download_button("⬇️ Download CSV",fsales.to_csv(index=False).encode("utf-8"),"filtered_sales.csv","text/csv")
        st.download_button("⬇️ Download Excel",to_excel_bytes(fsales),"filtered_sales.xlsx")

st.markdown("---")
st.markdown("<div style='text-align:center;color:#777;'>✨ Created by <strong>Md Ajam</strong></div>",unsafe_allow_html=True)
