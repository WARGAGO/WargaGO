# @markdown ### Model.py - EfficientNetV2 Model
import torch.nn as nn
from torchvision import models


class EfficientNetV2Model(nn.Module):
    def __init__(
        self,
        num_classes=5,
        dropout_rate=0.3,
        pretrained=True,
        freeze_backbone=False,
    ):
        super().__init__()

        # Load EfficientNetV2-S (Small) pretrained model
        if pretrained:
            weights = models.EfficientNet_V2_S_Weights.DEFAULT
            self.backbone = models.efficientnet_v2_s(weights=weights)
        else:
            self.backbone = models.efficientnet_v2_s(weights=None)

        # Freeze backbone if requested
        if freeze_backbone:
            for param in self.backbone.parameters():
                param.requires_grad = False

        # Get the number of features from the last layer
        in_features = self.backbone.classifier[1].in_features

        # Replace the classifier
        self.backbone.classifier = nn.Sequential(
            nn.Dropout(p=dropout_rate, inplace=True),
            nn.Linear(in_features, num_classes),
        )

        # Initialize the new classifier layer
        self._initialize_classifier()

    def _initialize_classifier(self):
        """Initialize the classifier layer"""
        for m in self.backbone.classifier.modules():
            if isinstance(m, nn.Linear):
                nn.init.kaiming_normal_(m.weight, mode="fan_out", nonlinearity="relu")
                if m.bias is not None:
                    nn.init.constant_(m.bias, 0)

    def forward(self, x):
        return self.backbone(x)

    def unfreeze_backbone(self):
        """Unfreeze all backbone parameters for fine-tuning"""
        for param in self.backbone.parameters():
            param.requires_grad = True
