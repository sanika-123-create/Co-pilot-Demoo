public virtual class AsyncOperationHandler {
	public String sourceClass;
	public String sourceMethod;
	public String sourceStackTrace;
	public String instanceType = String.valueOf(this)?.substring(0, String.valueOf(this).indexOf(':'));
	public Id jobId;
	public Datetime startTime;
	public String error;
	public Integer delayInMinutes;
	// protected Object asyncObject;
	public List<AsyncOperationHandler> queueableChain = new List<AsyncOperationHandler>();

	private static AsyncOperationHandler queuebleInstance; // this is set to the currently executing queueable execution in the transaction

	public void setSource(String sourceClass, String sourceMethod) {
		this.sourceClass = sourceClass;
		this.sourceMethod = sourceMethod;
		this.sourceStackTrace = SharedUtility.getStackTrace();
		startTime = Datetime.now();
	}

	public static Id enqueueJob(AsyncOperationHandler queueable) {
		Id jobId;
		if (System.isQueueable() && queuebleInstance != null) {
			queuebleInstance.queueableChain.add(queueable);
		} else if (System.isBatch() && queuebleInstance == null) {
			queuebleInstance = queueable;
		} else if (queuebleInstance != null) {
			queuebleInstance.queueableChain.add(queueable);
		} else {
			if (queueable.delayInMinutes != null) {
				jobId = System.enqueueJob(queueable, queueable.delayInMinutes);
			} else {
				jobId = System.enqueueJob(queueable);
			}
		}
		return jobId;
	}

	// this is for batch class
	@TestVisible
	protected void executeStart(Database.BatchableContext context) {
		// save all the async job details in the logs as INFO for future reference
		startTime = Datetime.now(); // to get the exact start time of the batch start method execution
		jobId = context?.getJobId();
	}

	@TestVisible
	protected void setFinalizer(Finalizer finalizer) {
		startTime = Datetime.now(); // to get the exact start time of the queueable
		System.attachFinalizer(finalizer);
		queuebleInstance = this;
	}

	@TestVisible
	protected void executeFinalizer(FinalizerContext context) {
		jobId = context?.getAsyncApexJobId();
		error = context?.getException() != null ? (context.getException().getMessage() + ' || ' + context.getException().getStackTraceString()) : null;
		createLog(sourceClass, sourceMethod);

		// execute other jobs chained in the flow
		AsyncOperationHandler nextQueueable = queueableChain?.isEmpty() == false ? queueableChain.remove(0) : null;
		if (nextQueueable != null && !Test.isRunningTest()) {
			nextQueueable.queueableChain = queueableChain;
			System.enqueueJob(nextQueueable);
		}
	}

	@TestVisible
	protected void executeBatchChunkFinalizer(Database.BatchableContext bc) {
		if (queuebleInstance != null) {
			System.enqueueJob(queuebleInstance);
		}
	}

	private void createLog(String sourceClass, String sourceMethod) {
		Log__c log = LogFactory.logAsyncJob(sourceClass, this);
		log.Start_Time__c = startTime ?? Datetime.now();
		log.End_Time__c = Datetime.now(); // to set the end time of the queueable
		log.Job_Id__c = jobId;
		LogFactory.saveLog();
	}
}