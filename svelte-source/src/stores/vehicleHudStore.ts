import { writable } from 'svelte/store'
import { capAmountToHundred } from '../types/types'

type vehicleStatusType = {
  revsColor: string,
  fuelColor: string,
  altitude: number,
  fuel: number,
  speed: number,
  show: boolean,
  showAltitude: boolean,
  showSeatBelt: boolean,
  showSquare: boolean,
  showSquareBorder: boolean,
  ShowCircle: boolean,
  showCircleBorder: boolean,
  gear: number,
  revs: number,
  seatbeltColor: string,
}

type vehicleHudUpdateMessageType = {
  show: boolean,
  isPaused: boolean,
  seatbelt: boolean,
  speed: number,
  fuel: number,
  altitude: number,
  showAltitude: boolean,
  showSeatbelt: boolean,
  showSquareB: boolean,
  showCircleB: boolean, 
  gear: number, 
  revs: number, 
}

type vehicleHudShowMessage = {
  show: boolean,
  seatbelt: boolean,
}


const store = () => {

  const vehicleStatusState: vehicleStatusType = {
    revsColor: "#FFFFFF",
    fuelColor: "#FFFFFF",
    altitude: 0,
    fuel: 0,
    speed: 0,
    show: false,
    showAltitude: false,
    showSeatBelt: false,
    showSquare: false,
    showSquareBorder: false,
    ShowCircle: false,
    showCircleBorder: false,
    gear: 0,
    revs: 0,
    seatbeltColor: "#e85b14",
  }

  const { subscribe, set, update } = writable(vehicleStatusState);

  const methods = {
    receiveShowMessage(data: vehicleHudShowMessage) {
      update(state => {
        state.show = data.show;
        state.showSeatBelt = data.seatbelt;
        return state;
      })
    },
    receiveUpdateMessage(data: vehicleHudUpdateMessageType) {
      update(state => {
        state.show = data.show;
        state.speed = data.speed;
        state.altitude = data.altitude;
        state.fuel = capAmountToHundred(data.fuel);
        state.showSeatBelt = data.showSeatbelt;
        state.showAltitude = data.showAltitude;
        state.showSquareBorder = data.showSquareB;
        state.showCircleBorder = data.showCircleB;
        state.gear = data.gear;
        state.revs = data.revs;

        if (data.seatbelt) {
          state.showSeatBelt = false;
        } else {
          state.showSeatBelt = true;
        }

        if (data.revs <= 20) {
          state.revsColor = "#FFFFFF";
        } else if (data.revs <= 30) {
          state.revsColor = "#FFFFFF";
        } else if (data.revs <= 40) {
          state.revsColor = "#fff700";
        } else if (data.revs <= 50) {
          state.revsColor = "#ffdd00";
        } else if (data.revs <= 60) {
          state.revsColor = "#ffc800";
        } else if (data.revs <= 70) {
          state.revsColor = "#ffa600";
        } else if (data.revs <= 80) {
          state.revsColor = "#ff8c00";
        } else if (data.revs <= 90) {
          state.revsColor = "#ff6600";
        } else {
          state.revsColor = "#ff0000";
        }

        if (data.fuel <= 20) {
          state.fuelColor = "#ff0000";
        } else if (data.fuel <= 30) {
          state.fuelColor = "#dd6e14";
        } else {
          state.fuelColor = "#FFFFFF";
        }

        if (data.isPaused) {
          state.show = false;
        }

        return state;
      });
    }
  }

  return {
    subscribe,
    set,
    update,
    ...methods
  }
}

export default store();