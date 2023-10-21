public with sharing class NPSOrderIds {
                 
        public String sfOrderId { get; set;}
        public String orderNum { get; set;}
        public String cusEmail { get; set;}
    
        public NPSOrderIds(Order order){
            this.sfOrderId = order.Id;
            this.orderNum = order.OrderNumber;
            this.cusEmail = order.BillToContact.Email;
        }
    
}