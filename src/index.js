import React, { useEffect, useState } from 'react';
import { StyleSheet, Text, View, TouchableHighlight, NativeModules, AppRegistry, Button,Platform } from 'react-native';

import { Provider } from 'react-redux';
import { useSelector } from 'react-redux';
import { useDispatch } from 'react-redux';

import store from './redux/store';

import { increment } from './redux/reducer';
import { decrement } from './redux/reducer';
import { reset } from './redux/reducer';

import AsyncStorage from '@react-native-async-storage/async-storage';


let MyCustomModule ;
let iframe;
if(Platform.OS != 'web'){
  MyCustomModule = NativeModules.MyCustomModule;
}


const AppScreen = () => {
  const dispatch = useDispatch()
  let val = {
    email:"myEmail@test.com",
    userName:"Foo",
    token:"dummyToken"
  }

  const storeData = async (value) => {
    try {
      const jsonValue = JSON.stringify(value)
      await AsyncStorage.setItem('user_data', jsonValue)
    } catch (e) {
      // saving error
    }
  }

  const getData = async () => {
    try {
      const value = await AsyncStorage.getItem('user_data')
      if(value !== null) {
        // value previously stored
        MyCustomModule.getStoreData(value).then(result => {
          console.log(result)
        });
      }
    } catch(e) {
      // error reading value
    }
  }

  useEffect(()=>{
    storeData(val);
    
   
   

  },[]);


  const counter = useSelector(state => {
    if(Platform.OS !== 'web'){
      MyCustomModule.getData(state.counter.toString(), 'param2').then(result => {
        console.log(result)
      });
    } else {
      window.setTimeout(() => {
      
        const jsonValue = {
         "event-id":"redux-data",
         "data":{
          "counter":state.counter
         }
        }
        
        var myIframe = document.getElementById('iframeElement');
        console.log(myIframe)
        iframe = window.parent.postMessage(JSON.stringify(jsonValue), "*");
        // use the iframe variable here
       
      }, 0);
    }
 
  return state.counter;
}
  );
 
  return (
    <View style={styles.container}>
      <Text style={styles.text}>{counter}</Text>
      <View style={{ flexDirection: "row" }}>
        <TouchableHighlight style={{ ...styles.button, backgroundColor: "red" }} onPress={() => { 
          dispatch(decrement()); 
         
        }}>
          <Text>-</Text>
        </TouchableHighlight>
        <TouchableHighlight style={{ ...styles.button, backgroundColor: "grey" }} onPress={() => {
           dispatch(reset()); 
           
          }}>
          <Text>Reset</Text>
        </TouchableHighlight>
        <TouchableHighlight style={{ ...styles.button, backgroundColor: "limegreen" }} onPress={() => { 
          dispatch(increment()); 
          
        }}>
          <Text>+</Text>
        </TouchableHighlight>
      </View>
      <Button title="Send Local Storage to Flutter" onPress={() => {
        getData()
      }}></Button>
    </View>
  )
}

export default function App() {
  return (
    <Provider store={store}>
      <AppScreen />
    </Provider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
  text: {
    fontSize: 100,
    fontWeight: "bold"
  },
  button: {
    width: 100,
    height: 50,
    margin: 1,
    justifyContent: "center",
    alignItems: "center",
    borderRadius: 10,
    borderColor: "black",
    borderStyle: "solid",
    borderWidth: 2
  }
});

  AppRegistry.registerComponent("IntegratedApp", () => App);
  if(Platform.OS === 'web'){
    AppRegistry.runApplication('IntegratedApp', {rootTag: document.getElementById('root')});

  }


