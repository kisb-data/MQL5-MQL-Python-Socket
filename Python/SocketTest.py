import SocketServer
import ast
import streamlit as st
import pandas as pd 
import altair as alt

# create connection
serv = SocketServer.SocketServer('127.0.0.1', 9090)

# empty vaules
placeholder = st.empty()
data = list()

while True:

    with placeholder.container():  
        msg = serv.SendReceive("Current data size on python side:" + str(len(data)))

        # convert message
        msg = ast.literal_eval(msg)
        if not type(msg) == dict:
            print("BAD JSON!!")

        if msg["Reset"][0]=="True":
            data = list()

        # get symbol data
        symbol = msg["Symbol"][0]

        # add received data to data list
        data.append(float(msg["CurPos"][0]))
        
        # Convert the data list to a pandas DataFrame
        df = pd.DataFrame({
            'index': range(len(data)),
            'value': data
        })

        df['cumsum'] = df['value'].cumsum()

        # Create an Altair line chart
        line_chart = alt.Chart(df).mark_line().encode(
            x='index:Q',
            y='cumsum:Q'
        ).properties(
            title='Sample Line Chart'
        )

        # Display the chart in Streamlit
        st.title("Altair Line Chart with random MQL position data.")
        st.write(f"Data is received from {symbol} chart.")
        st.altair_chart(line_chart, use_container_width=True)