@Metadata.allowExtensions: true
@ObjectModel.query.implementedBy: 'ABAP:ZLRAP100_CL_TRAVEL_Q'
define root custom entity ZLRAP100_R_TRAVELCE
{
  key travel_id     : /dmo/travel_id;

      @Consumption.valueHelpDefinition: [{entity: { name: '/DMO/I_Travel_Status_VH', element: 'TravelStatus'  }, useForValidation: true}]
      travel_status : /dmo/travel_status;
      
      //@Semantics.calendar.yearMonth: true
      //year_month : vdm_yearmonth;
      posting_date : budat;
      
      x : abap.char(10);
}

