
import copy
import numpy as np
import torch
from torch import nn
from torch.utils.data import DataLoader, Dataset

import pdb

import sys
sys.path.append('../../')
from FL.utils.dataclass import ClientsParams


# from FL.utils.utils import define_classification_model, softmax
# from FL.utils.dataclass import ClientsParams



class CreateDataset(Dataset):
    """
    An abstract Dataset class wrapped around Pytorch Dataset class.
    """

    def __init__(self, dataset, idxs):
        self.dataset = dataset
        self.idxs = [int(i) for i in idxs]

    def __len__(self):
        return len(self.idxs)

    def __getitem__(self, item):
        image, label = self.dataset[self.idxs[item]]
        return image, torch.tensor(label)


class LocalBase():
    def  __init__(self,args,train_dataset,test_dataset,client_id):
        self.args = args
        self.client_id = client_id
        self.trainDataset=CreateDataset(train_dataset, args.train_distributed_data[client_id])
        self.testDataset=CreateDataset(test_dataset, args.test_distributed_data[client_id])
        self.trainDataloader=DataLoader(self.trainDataset, args.batch_size, shuffle=True)
        self.testDataloader=DataLoader(self.testDataset, args.batch_size, shuffle=True)
        self.device = 'cuda' if args.on_cuda else 'cpu'
        self.criterion = nn.CrossEntropyLoss(reduction="mean")

        self.show_class_distribution(self.trainDataset,self.testDataset)
    
    def show_class_distribution(self,train,test):
        print("Class distribution of id:{}".format(self.client_id))
        class_distribution_train=[ 0 for _ in range(10)]
        class_distribution_test=[ 0 for _ in range(10)]
        for _, c in train:
            class_distribution_train[c]+=1
        for _, c in test:
            class_distribution_test[c]+=1
        print("train",class_distribution_train)
        print("test",class_distribution_test)


    # Add confusion matrix to test performance
    def local_validate(self,model):
        model.eval()
        model.to(self.device)
        correct = 0
        batch_loss = []
        with torch.no_grad():
            for images, labels in self.testDataloader:
                images, labels = images.to(self.device), labels.to(self.device)
                if images.shape[1]==1:
                    images=torch.cat((images, images, images), 1)
                output = model(images)
                pred = output.argmax(dim=1, keepdim=True)
                correct += pred.eq(labels.view_as(pred)).sum().item()
                loss = self.criterion(output, labels)
                batch_loss.append(loss.item())
        test_acc=100. * correct / len(self.testDataloader.dataset)
        test_loss=sum(batch_loss)/len(batch_loss)
        print('| Client id:{} | Test_Loss: {:.3f} | Test_Acc: {:.3f}'.format(self.client_id,test_loss, test_acc))
            
        return test_acc, test_loss

    def update_weights(self,model,global_epoch):
        model.train()
        model.to(self.device)
        
        if self.args.optimizer == 'sgd':
            optimizer = torch.optim.SGD(model.parameters(), lr=self.args.lr,momentum=0.9, weight_decay=5e-4)
        elif self.args.optimizer == 'adam':
            optimizer = torch.optim.Adam(model.parameters(), lr=self.args.lr, weight_decay=1e-4)
        
        for epoch in range(1,self.args.local_epochs+1):
            
            batch_loss = []
            correct = 0

            for batch_idx, (images, labels) in enumerate(self.trainDataloader):
                images, labels = images.to(self.device), labels.to(self.device)
                if images.shape[1]==1:
                    images=torch.cat((images, images, images), 1)

                optimizer.zero_grad()
                output = model(images)
                pred = output.argmax(dim=1, keepdim=True)  
                correct += pred.eq(labels.view_as(pred)).sum().item()
                
                loss = self.criterion(output, labels)
                loss.backward()
                #pdb.set_trace()

                optimizer.step()
                    
                #self.logger.add_scalar('loss', loss.item())、あとでどっかに学習のログ
                batch_loss.append(loss.item())

            train_acc,train_loss=100. * correct / len(self.trainDataloader.dataset),sum(batch_loss)/len(batch_loss)
            print('| Global Round : {}/{} | Client id:{} | Local Epoch : {}/{} |  Train_Loss: {:.3f} | Train_Acc: {:.3f}'.format(
                        global_epoch,self.args.global_epochs, self.client_id, epoch,self.args.local_epochs,train_loss, train_acc))
        
        return model.state_dict()      
        
class Fedavg_Local(LocalBase):
    def __init__(self,args,train_dataset,val_dataset,client_id):
        super().__init__(args,train_dataset,val_dataset,client_id)
    
    def localround(self,model,global_epoch,validation_only=False):
        
        self.local_validate(model)
        if validation_only:
            return 
        #update weights
        self.updated_weight=self.update_weights(model,global_epoch)
        
        clients_params=ClientsParams(weight=self.updated_weight)
        
        return clients_params

class Afl_Local(LocalBase):
    def __init__(self,args,train_dataset,val_dataset,client_id):
        super().__init__(args,train_dataset,val_dataset,client_id)
        
    def localround(self,model,global_epoch,validation_only=False):

        _, test_loss=self.local_validate(model)
        if validation_only:
            return 
        #update weights
        self.updated_weight=self.update_weights(model,global_epoch)
        
        clients_params=ClientsParams(weight=self.updated_weight,afl_loss=test_loss)
        return clients_params


     
def define_localnode(args,train_dataset,val_dataset,client_id):
    if args.federated_type=='fedavg':#normal
        return Fedavg_Local(args,train_dataset,val_dataset,client_id)
        
    elif args.federated_type=='afl':#afl
        return Afl_Local(args,train_dataset,val_dataset,client_id)

    else:       
        raise NotImplementedError     
    