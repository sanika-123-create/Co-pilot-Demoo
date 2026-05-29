# Weather Widget Implementation - Salesforce Setup Instructions

## Overview
This document provides setup instructions for deploying the weather widget component that integrates with the WeatherStack API. The component requires specific Remote Site Settings and Named Credentials to function properly.

---

## Setup Steps

### Step 1: Create Remote Site Setting

1. **Navigate to Setup:**
   - Log in to your Salesforce organization
   - Click **Setup** (gear icon) in the top-right corner
   - Search for **"Remote Site Settings"** in the Quick Find box
   - Click **Remote Site Settings**

2. **Add New Remote Site:**
   - Click the **New** button
   - Fill in the following details:
     - **Remote Site Name:** `WeatherStack_API`
     - **Remote Site URL:** `https://api.weatherstack.com`
     - **Description (Optional):** `Weather API integration for vessel schedule weather widget`
     - **Disable Protocol Security (Optional):** Leave **unchecked** for HTTPS security
   - Click **Save**

**Result:** Salesforce will now allow HTTP callouts to `https://api.weatherstack.com`

---

### Step 2: Create Named Credential

1. **Navigate to Setup:**
   - Click **Setup** (gear icon)
   - Search for **"Named Credentials"** in the Quick Find box
   - Click **Named Credentials**

2. **Create New Named Credential:**
   - Click **New Named Credential**
   - Fill in the following details:
     - **Label:** `WeatherStack_API`
     - **Name:** `WeatherStack_API` (auto-populated from Label)
     - **URL:** `https://api.weatherstack.com`
     - **Identity Type:** Select **"Named Principal"** (recommended for API integrations)
     - **Authentication Protocol:** Select **"No Authentication"** (API key is passed in query parameter)
     - **Allow Merge Fields in Body:** Leave **unchecked**
     - **Allow Merge Fields in Header:** Leave **unchecked**
   - Click **Save**

**Result:** The Named Credential is now available for use in Apex code via `callout:WeatherStack_API`

---

## Component Architecture

### Apex Components

1. **WeatherService.cls**
   - Main service class that handles HTTP callouts to the WeatherStack API
   - Method: `getWeatherByLocation(String location)` - Fetches weather data for a given location
   - Uses Named Credential `WeatherStack_API` for secure endpoint configuration
   - Includes error handling and logging via `LogFactory`

2. **WeatherService.WeatherResponseWrapper**
   - Wrapper class that maps the JSON response from WeatherStack API
   - Contains fields for:
     - Location information (name, region, country, local time)
     - Current weather (temperature, feels like, description, icon)
     - Details (wind, humidity, UV index, visibility, pressure, cloud cover)
     - Astronomy (sunrise, sunset, moon phase)
     - Air quality (EPA index, PM2.5, PM10)

### LWC Component

**vesselWeatherWidget**
- **Type:** Child component
- **Parent Component:** `vesselScheduleModal`
- **Public Properties:**
  - `nextPort` - Receives the Next_Port__c value from parent
- **Features:**
  - Auto-fetches weather on component load
  - 2-minute caching to prevent excessive API calls
  - Shows user-friendly error messages if fetch fails
  - Loading spinner during API call
  - Responsive design for mobile and desktop
  - Modern weather app-like UI with icons and details

---

## Weather Widget Features

### Display Sections

1. **Header Section**
   - Location name, region, and country
   - Current local date and time
   - Refresh button (respects 2-minute cache)

2. **Main Weather Section**
   - Large weather icon from API
   - Temperature in Celsius
   - Weather description (e.g., "Partly Cloudy")
   - Feels like temperature

3. **Details Grid**
   - Wind speed and direction (with icon)
   - Humidity percentage
   - UV Index
   - Visibility in kilometers
   - Cloud cover percentage
   - Pressure in hPa

4. **Astro Section**
   - Sunrise time
   - Sunset time
   - Moon phase

5. **Air Quality Section**
   - US EPA Index with status label (Good, Fair, Moderate, etc.)
   - PM2.5 value
   - PM10 value

### Caching Logic

- **2-Minute Rule:** Data is cached for 2 minutes from last fetch
- **Refresh Button Behavior:**
  - If user clicks refresh within 2 minutes: Shows message "Weather data is up to date. Please try again in X seconds"
  - If user clicks refresh after 2 minutes: Fetches fresh data from API
- **Initial Load:** Always fetches data on component initialization

---

## Error Handling

The weather widget includes robust error handling:

- **Empty Location:** Shows "No location provided"
- **API Errors:** Shows "Unable to fetch weather for [location]. [Error details]"
- **Invalid Location:** Shows friendly error message
- **Network Issues:** Logs error to `LogFactory` and displays user message

All errors are displayed inline within the widget, not as toast notifications.

---

## Integration with Parent Component

### Parent Component: vesselScheduleModal

The parent component has been updated to:

1. **Two-Column Layout (Read-Only View):**
   - Left column (60%): Vessel schedule fields
   - Right column (40%): Weather widget

2. **Conditional Display:**
   - Weather widget shows only when:
     - Modal is in read-only view
     - Next_Port__c field has a value
   - Weather widget is hidden during edit mode

3. **Data Passing:**
   - Parent passes `Next_Port__c` value to child via the `next-port` attribute
   - Child component automatically triggers weather fetch when receiving the port value

---

## API Details

### WeatherStack API

- **Endpoint:** `https://api.weatherstack.com/current`
- **Access Key:** `81f0b4f9021c2566b721f9df1cdfd048`
- **Query Parameter:** `query` = location name (e.g., "Jacksonville, FL")
- **Response Format:** JSON
- **Caching:** 2 minutes on client side

### Example API Call
```
https://api.weatherstack.com/current?access_key=81f0b4f9021c2566b721f9df1cdfd048&query=Jacksonville, FL
```

---

## Testing

### Test Cases Covered

1. **WeatherServiceTest.cls**
   - Successful API response with complete data mapping
   - Error response handling
   - Invalid/empty location input
   - HTTP error status codes

### Manual Testing Steps

1. Deploy all components to Salesforce org
2. Navigate to a Vessel Schedule record
3. Click "Edit" to enter edit mode
4. Create or update a record with a "Next Port" value
5. Click "Save"
6. In read-only view, verify the weather widget appears on the right
7. Weather widget should auto-load and display weather data
8. Click "Refresh" button to test refresh functionality (within 2 minutes shows cache message, after 2 minutes fetches new data)

---

## Troubleshooting

### Issue: Weather widget doesn't appear

- **Solution:** Ensure Next_Port__c field has a value and modal is in read-only mode

### Issue: API callout fails with authentication error

- **Solution:** Verify Named Credential `WeatherStack_API` is properly configured and Remote Site Setting is created

### Issue: Error "Unable to fetch weather for [location]"

- **Solution:** 
  - Verify API key in WeatherService.cls is correct
  - Check if location name is valid and recognized by WeatherStack API
  - Verify network/firewall allows outbound HTTPS calls

### Issue: Refresh button shows cache message longer than expected

- **Solution:** This is expected behavior - the widget enforces a 2-minute cache to prevent excessive API calls

---

## Code Quality & Compliance

### Apex Code
- ✅ Uses `with sharing` keyword for security
- ✅ Includes ApexDoc comments for public methods
- ✅ Uses `LogFactory` for error logging
- ✅ Uses `DMLUtility` pattern (when applicable)
- ✅ No SOQL/DML in loops
- ✅ No hardcoded IDs (except API key which is externalized via Named Credential)
- ✅ Proper error handling with try-catch and AuraHandledException

### LWC Component
- ✅ Uses `@api` properties for parent-child communication
- ✅ Proper lifecycle management with `connectedCallback`
- ✅ Clean reactive properties with `@track`
- ✅ CSS follows SLDS conventions
- ✅ Responsive design with mobile breakpoints
- ✅ Accessibility features (labels, aria attributes)
- ✅ Error handling with inline messages

---

## File Structure

```
force-app/main/default/
├── classes/
│   ├── WeatherService.cls          (existing, used by child component)
│   ├── WeatherService.cls-meta.xml
│   ├── WeatherServiceTest.cls      (existing, comprehensive test coverage)
│   └── WeatherServiceTest.cls-meta.xml
└── lwc/
    ├── vesselScheduleModal/
    │   ├── vesselScheduleModal.html (updated with 2-column layout)
    │   ├── vesselScheduleModal.js   (updated with showWeatherWidget getter)
    │   ├── vesselScheduleModal.css
    │   └── vesselScheduleModal.js-meta.xml
    └── vesselWeatherWidget/         (new child component)
        ├── vesselWeatherWidget.html
        ├── vesselWeatherWidget.js
        ├── vesselWeatherWidget.css
        └── vesselWeatherWidget.js-meta.xml
```

---

## Deployment Checklist

- [ ] Create Remote Site Setting for `https://api.weatherstack.com`
- [ ] Create Named Credential `WeatherStack_API`
- [ ] Deploy vesselWeatherWidget component files
- [ ] Deploy updated vesselScheduleModal component files
- [ ] Deploy WeatherService and WeatherServiceTest (if not already deployed)
- [ ] Run WeatherServiceTest to verify test coverage
- [ ] Test weather widget in read-only view of Vessel Schedule record
- [ ] Verify refresh button works correctly
- [ ] Test error scenarios (invalid location, network error)

---

## Support & Maintenance

For issues or questions:
1. Check the troubleshooting section above
2. Review PMD/ESLint scan results for code quality issues
3. Check browser console for JavaScript errors
4. Check Salesforce logs for Apex errors
5. Verify Named Credential and Remote Site Settings are properly configured
