#ifndef SHADERMODEL_H
#define SHADERMODEL_H

#include <QObject>
#include <Qt3DRender/QShaderProgram>
#include <QStandardItemModel>
#include "shaderparameterinfo.h"

class ShaderParameterInfo;

class ShaderModel : public QStandardItemModel
{
    Q_OBJECT
    Q_PROPERTY(Qt3DRender::QShaderProgram *shaderProgram READ shaderProgram WRITE setShaderProgram NOTIFY shaderProgramChanged)
    Q_PROPERTY(QStringList blacklist READ blacklist WRITE setBlacklist NOTIFY blacklistChanged)
public:
    enum ShaderParameterRoles {
        ParameterName = Qt::DisplayRole,
        ParameterType = Qt::ToolTipRole,
        ParameterDatatype = Qt::UserRole,
        ParameterValue = Qt::UserRole + 1,
        ParameterUniformLocation = Qt::UserRole + 2,
        ParameterIsSubroutine = Qt::UserRole + 3,
        ParameterSubroutineValues = Qt::UserRole + 4,
        ParameterData = Qt::UserRole + 5 // This is used for creation of ui elements
    };
    Q_ENUM(ShaderParameterRoles)

    ShaderModel();
    ShaderModel(const ShaderModel &other);
    Qt3DRender::QShaderProgram *shaderProgram() const;
    Q_INVOKABLE void syncModel();
    QStringList blacklist() const;

public Q_SLOTS:
    void setShaderProgram(Qt3DRender::QShaderProgram *shaderProgram);
    void setBlacklist(QStringList blacklist);
    QHash<int, QByteArray> roleNames() const;
Q_SIGNALS:
    void shaderProgramChanged(Qt3DRender::QShaderProgram *shaderProgram);
    void blacklistChanged(QStringList blacklist);

private:
    Qt3DRender::QShaderProgram *m_shaderProgram;
    QHash<int, QByteArray> m_roleNameMapping;
    QStringList m_blacklist;
    QHash<QString, ShaderParameterInfo*> m_parameters;
};

Q_DECLARE_METATYPE(ShaderModel)
Q_DECLARE_METATYPE(ShaderModel::ShaderParameterRoles)

#endif // SHADERMODEL_H
