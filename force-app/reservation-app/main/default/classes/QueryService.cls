public with sharing class QueryService extends ZD_VirtualCallable{
    
    @TestVisible private SOQL.Builder builder;

    public override Object doCall(String action, Map<String,Object> args){
        switch on action {
            when 'setobject' {
                String objectType = String.valueOf(args.get('objectType'));
                builder = new SOQL.Builder(objectType);
                return this;
            }
            when 'selectfield' {
                String field = String.valueOf(args.get('field'));
                builder.selectField(field);
                return this;
            }
            when 'withwhereclause'{
                String field = String.valueOf(args.get('field'));
                String value = String.valueOf(args.get('value'));
                Query.Condition condition = new Query.Condition().equals(field, new Query.DateLiteral('LAST_N_DAYS', 30));
                builder.whereCondition(condition);
                return this;
            }
            when 'build'{
                return builder.build().getQueryString() ;
            }
        }
        return null;
    }
    
}