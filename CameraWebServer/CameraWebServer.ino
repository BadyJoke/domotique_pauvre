#include "esp_camera.h"
#include <WiFi.h>
#include "driver/adc.h"

//
// WARNING!!! PSRAM IC required for UXGA resolution and high JPEG quality
//            Ensure ESP32 Wrover Module or other board with PSRAM is selected
//            Partial images will be transmitted if image exceeds buffer size
//

// Select camera model
//#define CAMERA_MODEL_WROVER_KIT // Has PSRAM
//#define CAMERA_MODEL_ESP_EYE // Has PSRAM
//#define CAMERA_MODEL_M5STACK_PSRAM // Has PSRAM
//#define CAMERA_MODEL_M5STACK_V2_PSRAM // M5Camera version B Has PSRAM
//#define CAMERA_MODEL_M5STACK_WIDE // Has PSRAM
//#define CAMERA_MODEL_M5STACK_ESP32CAM // No PSRAM
  #define CAMERA_MODEL_AI_THINKER // Has PSRAM
//#define CAMERA_MODEL_TTGO_T_JOURNAL // No PSRAM

#include "camera_pins.h"

const char* ssid = "Octavewifi";
const char* password = "1234567890";

void startCameraServer();
void stopCameraServer();

bool isUserConnected();
bool isUp();
bool isDown();
bool isEnd();

bool setUp(bool value);
bool setDown(bool value);
bool setEnd(bool value);

void setModemSleep();
void wakeModemSleep();
void disableBluetooth();
void enableWiFi();

bool isUserConnected();

// Motor A
int motor1Pin1 = 15; 
int motor1Pin2 = 14; 
int enable1Pin = 13; 

// Setting PWM properties
const int freq = 30000;
const int pwmChannel = 2;
const int resolution_motor = 8;
int dutyCycle = 200;

void setup() {
  
  Serial.begin(115200);
  Serial.setDebugOutput(true);
  Serial.println();

  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;
  
  // if PSRAM IC present, init with UXGA resolution and higher JPEG quality
  //                      for larger pre-allocated frame buffer.
  if(psramFound()){
    config.frame_size = FRAMESIZE_UXGA;
    config.jpeg_quality = 10;
    config.fb_count = 2;
  } else {
    config.frame_size = FRAMESIZE_SVGA;
    config.jpeg_quality = 12;
    config.fb_count = 1;
  }

  // camera init
  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Camera init failed with error 0x%x", err);
    return;
  }

  sensor_t * s = esp_camera_sensor_get();
  // initial sensors are flipped vertically and colors are a bit saturated
  if (s->id.PID == OV3660_PID) {
    s->set_vflip(s, 1); // flip it back
    s->set_brightness(s, 1); // up the brightness just a bit
    s->set_saturation(s, -2); // lower the saturation
  }
  // drop down frame size for higher initial frame rate
  s->set_framesize(s, FRAMESIZE_QVGA);

#if defined(CAMERA_MODEL_M5STACK_WIDE) || defined(CAMERA_MODEL_M5STACK_ESP32CAM)
  s->set_vflip(s, 1);
  s->set_hmirror(s, 1);
#endif

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");

  startCameraServer();

  Serial.print("Camera Ready! Use 'http://");
  Serial.print(WiFi.localIP());
  Serial.println("' to connect");

  disableBluetooth();

  setModemSleep();
  Serial.println("MODEM SLEEP ENABLED");
}

unsigned long previousMillis = 0;
long wake_interval = 8000; 
long sleep_interval = 11000;
bool started = false;
bool serverStarted = false;

void loop() {

  unsigned long currentMillis = millis();

  if(!isUserConnected()){
    
    if(!started && currentMillis - previousMillis > sleep_interval){
      wakeModemSleep();
      Serial.println("MODEM SLEEP DISABLED");
      started = true;
      previousMillis = currentMillis;
    }

    if(started && currentMillis - previousMillis > wake_interval){
      setModemSleep();
      Serial.println("MODEM SLEEP ENABLED");
      started = false;
    }
  }
  else{

    
    
    if(isUp()){ 
      Serial.println("Sending up to motor");
      digitalWrite(motor1Pin1, LOW);
      digitalWrite(motor1Pin2, HIGH);
      setUp(false);
    }

    if(isDown()){
      Serial.println("Sending down to motor");
      digitalWrite(motor1Pin1, HIGH);
      digitalWrite(motor1Pin2, LOW); 
      setDown(false);
    }

    if(isEnd()){
      Serial.println("Sending end to motor");
      digitalWrite(motor1Pin1, LOW);
      digitalWrite(motor1Pin2, LOW);
      setEnd(false);
    }
  }
}

void disableBluetooth(){
  btStop();
  Serial.println("Bluetooth stop");
}

void disableWiFi(){
  adc_power_off();
  WiFi.disconnect(true);  // Disconnect from the network
  WiFi.mode(WIFI_OFF);    // Switch WiFi off
}

void setModemSleep(){
  disableWiFi();
  setCpuFrequencyMhz(40);
  Serial.println("MODEM SLEEP");
}

void wakeModemSleep(){
  setCpuFrequencyMhz(80);
  setupMotor();
  enableWiFi();

  Serial.println("MODEM WAKE");
}

void setupMotor(){
  pinMode(motor1Pin1, OUTPUT);
  pinMode(motor1Pin2, OUTPUT);
  pinMode(enable1Pin, OUTPUT);
  
  // configure LED PWM functionalitites
  ledcSetup(pwmChannel, freq, resolution_motor);
  
  // attach the channel to the GPIO to be controlled
  ledcAttachPin(enable1Pin, pwmChannel);

  ledcWrite(pwmChannel, dutyCycle); 
}

void enableWiFi(){
    adc_power_on();
    delay(200);
 
    WiFi.disconnect(false);  // Reconnect the network
    WiFi.mode(WIFI_STA);    // Switch WiFi off
 
    delay(200);
 
    Serial.println("START WIFI");
    WiFi.begin(ssid, password);
 
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
 
    Serial.println("");
    Serial.println("WiFi connected");
    Serial.println("IP address: ");
    Serial.println(WiFi.localIP());
}
